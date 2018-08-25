//
//  NSPersistentStoreDescription.swift
//  CoreDataStack
//
//  Created by Sergey Kostyan on 25.08.2018.
//  Copyright © 2018 Sergey Kostyan. All rights reserved.
//

import Foundation
import CoreData

extension NSPersistentStoreDescription {
    
    convenience init(with storeURL: URL, type: String) {
        self.init(url: storeURL)
        self.type = type
        self.shouldMigrateStoreAutomatically = true
        self.shouldInferMappingModelAutomatically = true
    }
    
}
