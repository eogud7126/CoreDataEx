//
//  UserCRUD.swift
//  CoreDataEx
//
//  Created by USER on 23/07/2020.
//  Copyright © 2020 USER. All rights reserved.
//

import Foundation
import CoreData

class UserCRUD{
    fileprivate let persistenceManager: PersistenceManager!
    fileprivate var mainContextInstance: NSManagedObjectContext!
    
    class var sharedInstance: UserCRUD{
        struct Singleton{
            static let instance = UserCRUD()
        }
        return Singleton.instance
    }
    
    init(){
        self.persistenceManager = PersistenceManager.sharedInstance
        self.mainContextInstance = persistenceManager.getMainContextInstance()
    }
    
    
    //MARK: - Create
    
    func insert(_ user: User){
        //Minion Context worker with Private Concurrency type
        let minionManagedObjectContextWorker: NSManagedObjectContext = NSManagedObjectContext.init(concurrencyType: .privateQueueConcurrencyType)
        minionManagedObjectContextWorker.parent = self.mainContextInstance
        
        //Create new Object of Event entity
        let userObject = NSEntityDescription.insertNewObject(forEntityName: "User", into: minionManagedObjectContextWorker) as! User
        
        userObject.name = user.name
        userObject.age = user.age
        
        //Save current worker on minion workers
        self.persistenceManager.saveWorkerContext(minionManagedObjectContextWorker)
        
        //save and merge changes from minion workers with main context
        self.persistenceManager.mergeWithMainContext()
        
        //post notification to update datasource of a given ViewController/UITableView
        self.postUpdateNotification()
    }
    
    
    //MARK: - Read
    
    func fetchUsers(_ sortedByName: Bool = true, sortAscending: Bool = true, keyword text: String? = nil) -> [User] {
        var fetchResults: [User] = [User]()
        
        //create request on user entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        //create sort descriptor to sort retrieved Users by Name, ascending
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: sortAscending)
        //배열로 만들어서 넣어줘야한다.
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = sortDescriptors
        
        //검색창에 키워드 있을 경우
        if let text = text, text.isEmpty == false{
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[c] %@", text)
        }
        
        //Execute Fetch Reqeust
        do{
            fetchResults = try self.mainContextInstance.fetch(fetchRequest) as! [User]
        }catch let fetchError as NSError{
            print("retrieveByName error: \(fetchError.localizedDescription)")
            fetchResults = [User]()
        }
        return fetchResults
    }
    
    
    func fetchUsersInAgeRange(_ sortByAge: Bool = true, sortAscending: Bool = true, startAge: Int16, endAge: Int16) -> [User]{
        //create request on user entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        //create sort descriptor to sort retrieced users by name, ascending
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = sortDescriptors
        
        //create predicate to filter by start- /end age
        let findByAgeRangePredicate = NSPredicate(format: "age >= %@ AND age <= %@", startAge,endAge)
        fetchRequest.predicate = findByAgeRangePredicate
        
        //execute fetch request
        var fetchResults = [User]()
        do{
            fetchResults = try self.mainContextInstance.fetch(fetchRequest) as! [User]
        }catch let fetchError as NSError{
            print("agerange error:\(fetchError.localizedDescription)")
        }
        
        return fetchResults
    }
    
    
    //MARK: - Update
    
    func updateUserInfo(_ userId: NSManagedObjectID, newUserDetails: User){
        let minionManagedObjectContextWorker: NSManagedObjectContext = NSManagedObjectContext.init(concurrencyType: .privateQueueConcurrencyType)
        minionManagedObjectContextWorker.parent = self.mainContextInstance
        
        let userToUpdate = minionManagedObjectContextWorker.object(with: userId)
        //Assign field values
        userToUpdate.setValue(newUserDetails.name, forKey: "name")
        userToUpdate.setValue(newUserDetails.age, forKey: "age")
            
        
        //Persist new User to datasource
        self.persistenceManager.saveWorkerContext(minionManagedObjectContextWorker)
        self.persistenceManager.mergeWithMainContext()
        
        self.postUpdateNotification()
    }
    
    //MARK: - Delete
    
    func delete(_ userId: NSManagedObjectID){
        let object = self.mainContextInstance.object(with: userId)
        
        self.mainContextInstance.delete(object)
        self.persistenceManager.mergeWithMainContext()
        
        self.postUpdateNotification()
    }
    
    
    
    fileprivate func postUpdateNotification(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateUserTableData"), object: nil)
    }
    
}
