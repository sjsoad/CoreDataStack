//
//  CoreDataStack.swift
//  CoreDataStack
//
//  Created by Sergey Kostyan on 25.08.2018.
//  Copyright © 2018 Sergey Kostyan. All rights reserved.
//

import CoreData

public protocol CoreDataStack {
    
    var mainContext: NSManagedObjectContext { get }
    
    func importerContext() -> NSManagedObjectContext
    func editorContext() -> NSManagedObjectContext
    
}
