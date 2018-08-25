//
//  DefaultCoreDataStack.swift
//  CoreDataStack
//
//  Created by Sergey Kostyan on 24.08.2018.
//  Copyright © 2018 Sergey Kostyan. All rights reserved.
//

import CoreData

open class DefaultCoreDataStack: CoreDataStack {

    public let dataModel: NSManagedObjectModel

    public let mainCoordinator: NSPersistentStoreCoordinator
    public let writerCoordinator: NSPersistentStoreCoordinator
    
    public let mainContext: NSManagedObjectContext
    public var viewContext: NSManagedObjectContext { return mainContext }
    
    // MARK: - Static -
    
    public static var defaultStoreFolderURL: URL {
        return FileManager.default.documentDirectoryURL
    }
    
    public static var defaultStoreFileName: String {
        return "\(Bundle.main.appName).sqlite"
    }
    
    public static var defaultStoreURL: URL {
        return defaultStoreFolderURL.appendingPathComponent(defaultStoreFileName)
    }
    
    public static func buildAsync(withDataModelNamed dataModelName: String? = nil, storeURL: URL = DefaultCoreDataStack.defaultStoreURL,
                                  storeType: String = NSInMemoryStoreType, completion: @escaping (CoreDataStack) -> Void) {
        DispatchQueue.global().async {
            let coreDataStack = DefaultCoreDataStack(withDataModelNamed: dataModelName, storeURL: storeURL, storeType: storeType)
            DispatchQueue.main.async {
                completion(coreDataStack)
            }
        }
    }
    
    // MARK: - Lifecycle -
    
    public init(withDataModelNamed dataModelName: String? = nil, storeURL: URL = DefaultCoreDataStack.defaultStoreURL,
                storeType: String = NSInMemoryStoreType) {
        self.dataModel = NSManagedObjectModel.model(named: dataModelName)
        self.mainCoordinator = NSPersistentStoreCoordinator(managedObjectModel: dataModel)
        self.writerCoordinator = NSPersistentStoreCoordinator(managedObjectModel: dataModel)
        self.mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType, coordinator: mainCoordinator,
                                                  mergePolicy: NSMergeByPropertyStoreTrumpMergePolicy)
        let storeDescription = NSPersistentStoreDescription(with: storeURL, type: storeType)
        self.connectStore(toCoordinator: mainCoordinator, with: storeDescription)
        self.connectStore(toCoordinator: writerCoordinator, with: storeDescription)
        self.subscribeForNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .NSManagedObjectContextDidSave, object: nil)
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
    
    private func subscribeForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handle), name: .NSManagedObjectContextDidSave, object: nil)
    }
    
    // MARK: - Notifications handle -
    
    @objc private func handle(notification: Notification) {
        guard let savedContext = notification.object as? NSManagedObjectContext else { return }
        if savedContext === mainContext { return }
        if let parentContext = savedContext.parent {
            if parentContext === mainContext { return }
        }
        if let coordinator = savedContext.persistentStoreCoordinator {
            if coordinator !== mainCoordinator && coordinator !== writerCoordinator { return }
        }
        mainContext.perform({ [weak self] in
            self?.mainContext.mergeChanges(fromContextDidSave: notification)
        })
    }
    
    // MARK: - Public -
    
    public func importerContext() -> NSManagedObjectContext {
        return NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType, coordinator: writerCoordinator,
                                      mergePolicy: NSMergeByPropertyObjectTrumpMergePolicy)
    }
    
    public func editorContext() -> NSManagedObjectContext {
        return NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType, parentContext: mainContext,
                                      mergePolicy: NSMergeByPropertyObjectTrumpMergePolicy)
    }
    
}
