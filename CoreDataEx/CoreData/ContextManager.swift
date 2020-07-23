//
//  ContextManager.swift
//  CoreDataEx
//
//  Created by USER on 23/07/2020.
//  Copyright © 2020 USER. All rights reserved.
//

import Foundation
import CoreData

class ContextManager: NSObject{

    override init() {
        let appDelegate: AppDelegate = AppDelegate().sharedInstance()
        super.init()
    }
    
    //Create master context reference, with privateQueueConcurrency type
    lazy var masterManagedObjectContextInstance: NSManagedObjectContext = {
        var masterManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        return masterManagedObjectContext
    }()
    
    //create main context reference with, MainQueue
    lazy var mainManagedObjectContextInstance: NSManagedObjectContext = {
        var mainManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        return mainManagedObjectContext
    }()
    
    func saveContext(){
        defer{
            do{
                try masterManagedObjectContextInstance.save()
            }catch let masterMOCSaveError as NSError {
                print("Master Managed Obnject Context save error: \(masterMOCSaveError.localizedDescription)")
            }catch {
                print("Master Managed Object Context save error.")
            }
            
        }
        if mainManagedObjectContextInstance.hasChanges{
            mergeChangeFromMainContext()
        }
    }
    
    fileprivate func mergeChangeFromMainContext(){
        DispatchQueue.main.async(execute: {
            do{
                try self.mainManagedObjectContextInstance.save()
            }catch let MOCSaveError as NSError{
                print("Master Managed Object Context error: \(MOCSaveError.localizedDescription)")
            }
        })
    }
    
}
