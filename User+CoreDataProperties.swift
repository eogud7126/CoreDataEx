//
//  User+CoreDataProperties.swift
//  CoreDataEx
//
//  Created by USER on 23/07/2020.
//  Copyright © 2020 USER. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var name: String?
    @NSManaged public var age: Int16

}
