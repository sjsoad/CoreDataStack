//
//  NSManagedObjectContext.swift
//  CoreDataStack
//
//  Created by Sergey Kostyan on 25.08.2018.
//  Copyright © 2018 Sergey Kostyan. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    
    convenience init(concurrencyType: NSManagedObjectContextConcurrencyType, coordinator: NSPersistentStoreCoordinator, mergePolicy: AnyObject) {
        self.init(concurrencyType: concurrencyType)
        self.persistentStoreCoordinator = coordinator
        self.mergePolicy = mergePolicy
    }
    
    convenience init(concurrencyType: NSManagedObjectContextConcurrencyType, parentContext: NSManagedObjectContext, mergePolicy: AnyObject) {
        self.init(concurrencyType: concurrencyType)
        self.parent = parentContext
        self.mergePolicy = mergePolicy
    }
    
    public func save(_ callback: @escaping (Error?) -> Void = {_ in}) {
        if !hasChanges {
            callback(nil)
        }
        performAndWait {
            do {
                try save()
                guard let parentContext = parent else {
                    callback(nil)
                    return
                }
                parentContext.save(callback)
            } catch(let error) {
                callback(error)
            }
        }
    }
    
}
