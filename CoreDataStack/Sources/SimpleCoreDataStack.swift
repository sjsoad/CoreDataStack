//
//  SimpleCoreDataStack.swift
//  CoreDataStack
//
//  Created by Sergey Kostyan on 26.08.2018.
//  Copyright © 2018 Sergey Kostyan. All rights reserved.
//

import CoreData

public class SimpleCoreDataStack: CoreDataStack {
    
    public let mainContext: NSManagedObjectContext
    
    private let dataModel: NSManagedObjectModel
    private let mainCoordinator: NSPersistentStoreCoordinator
    private let privateContext: NSManagedObjectContext
    
    // MARK: - Static -
    
    public class var defaultStoreFolderURL: URL {
        return FileManager.default.documentDirectoryURL
    }
    
    public class var defaultStoreFileName: String {
        return "\(Bundle.main.appName).sqlite"
    }
    
    public class var defaultStoreURL: URL {
        return defaultStoreFolderURL.appendingPathComponent(defaultStoreFileName)
    }
    
    public class func buildAsync(withDataModelNamed dataModelName: String? = nil, storeURL: URL = SimpleCoreDataStack.defaultStoreURL,
                                  storeType: String = NSInMemoryStoreType, completion: @escaping (CoreDataStack) -> Void) {
        DispatchQueue.global().async {
            let coreDataStack = SimpleCoreDataStack(withDataModelNamed: dataModelName, storeURL: storeURL, storeType: storeType)
            DispatchQueue.main.async {
                completion(coreDataStack)
            }
        }
    }
    
    // MARK: - Lifecycle -
    
    public init(withDataModelNamed dataModelName: String? = nil, storeURL: URL = SimpleCoreDataStack.defaultStoreURL,
                storeType: String = NSInMemoryStoreType) {
        self.dataModel = NSManagedObjectModel.model(named: dataModelName)
        self.mainCoordinator = NSPersistentStoreCoordinator(managedObjectModel: dataModel)
        self.privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType, coordinator: mainCoordinator,
                                                     mergePolicy: NSMergeByPropertyStoreTrumpMergePolicy)
        self.mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType, parentContext: privateContext,
                                                  mergePolicy: NSMergeByPropertyStoreTrumpMergePolicy)
        let storeDescription = NSPersistentStoreDescription(with: storeURL, type: storeType)
        self.connectStore(toCoordinator: mainCoordinator, with: storeDescription)
    }
    
    // MARK: - Private -
    
    private func connectStore(toCoordinator psc: NSPersistentStoreCoordinator, with storeDescription: NSPersistentStoreDescription) {
        psc.addPersistentStore(with: storeDescription, completionHandler: { [unowned self] (sd, error) in
            if let error = error {
                let log = String(format: "E | %@:%@/%@ Error adding persistent stores to coordinator %@:\n%@",
                                 String(describing: self), #file, #line, String(describing: psc), error.localizedDescription)
                fatalError(log)
            }
        })
    }
    
    // MARK: - Public -
    
    public func importerContext() -> NSManagedObjectContext {
        return NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType, parentContext: privateContext,
                                      mergePolicy: NSMergeByPropertyObjectTrumpMergePolicy)
    }
    
    public func editorContext() -> NSManagedObjectContext {
        return NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType, parentContext: mainContext,
                                      mergePolicy: NSMergeByPropertyObjectTrumpMergePolicy)
    }
    
}
