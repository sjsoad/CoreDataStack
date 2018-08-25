//
//  NSManagedObjectModel.swift
//  CoreDataStack
//
//  Created by Sergey Kostyan on 25.08.2018.
//  Copyright © 2018 Sergey Kostyan. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectModel {
    
    static func model(named name: String? = nil) -> NSManagedObjectModel {
        guard let name = name, let mom = NSManagedObjectModel(with: name) else {
            guard let mom = NSManagedObjectModel.mergedModel(from: nil) else {
                let log = String(format: "E | %@:%@/%@ Unable to create ManagedObjectModel by merging all models in the main bundle",
                                 String(describing: self), #file, #line)
                fatalError(log)
            }
            return mom
        }
        return mom
    }
    
    convenience init?(with name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "momd") else {
            let log = String(format: "E | %@/%@ Unable to create ManagedObjectModel using name %@", #file, #line, name)
            fatalError(log)
        }
        self.init(contentsOf: url)
    }
    
}
