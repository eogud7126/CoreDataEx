//
//  PersistenceManager.swift
//  CoreDataEx
//
//  Created by USER on 23/07/2020.
//  Copyright © 2020 USER. All rights reserved.
//

import Foundation
import CoreData

class PersistenceManager: NSObject {
    fileprivate var appDelegate: AppDelegate
    fileprivate var mainContextInstance: NSManagedObjectContext
    
    class var sharedInstance: PersistenceManager{
        struct Singleton {
            static let instance = PersistenceManager()
        }
        return Singleton.instance
    }
    
    override init() {
        appDelegate = AppDelegate().sharedInstance()
        mainContextInstance = ContextManager.init().mainManagedObjectContextInstance
        super.init()
    }
    
    func getMainContextInstance() -> NSManagedObjectContext{
        return self.mainContextInstance
    }
    
    func saveWorkerContext(_ workerContext: NSManagedObjectContext){
        do{
            try workerContext.save()
        }catch let saveError as NSError{
            print("save mini worker error: \(saveError.localizedDescription)")
        }
    }
    
    func mergeWithMainContext(){
        do{
            try self.mainContextInstance.save()
        } catch let saveError as NSError{
            print("syncWith MainContext Error: \(saveError.localizedDescription)")
        }
    }
    
}
