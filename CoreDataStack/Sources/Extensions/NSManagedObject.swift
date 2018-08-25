//
//  NSManagedObject.swift
//  CoreDataStack
//
//  Created by Sergey Kostyan on 25.08.2018.
//  Copyright © 2018 Sergey Kostyan. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    public static let defaultPredicateType: NSCompoundPredicate.LogicalType = .and
    
    class var entityName: String {
        return String(describing: self)
    }

    class func createFetchRequest<T: NSManagedObject>(predicate: NSPredicate? = nil,
                                                      sortDescriptors: [NSSortDescriptor]? = nil) -> NSFetchRequest<T> {
        let request = NSFetchRequest<T>(entityName: entityName)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return request
    }
    
    class func createPredicate(with attributes: [AnyHashable : Any],
                               predicateType: NSCompoundPredicate.LogicalType = defaultPredicateType) -> NSPredicate {
        var predicates = [NSPredicate]()
        attributes.forEach { (attribute, value) in
            predicates.append(NSPredicate(format: "%K = %@", argumentArray: [attribute, value]))
        }
        let compoundPredicate = NSCompoundPredicate(type: predicateType, subpredicates: predicates)
        return compoundPredicate
    }
    
    class func fetchedResultsController<T: NSManagedObject>(in context: NSManagedObjectContext, sectionNameKeyPath: String? = nil,
                                        predicate: NSPredicate? = nil, sortedWith sortDescriptors: [NSSortDescriptor]? = nil
        ) -> NSFetchedResultsController<T>? {
        let request = createFetchRequest(predicate: predicate, sortDescriptors: sortDescriptors)
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath,
                                             cacheName: nil)
        return frc as? NSFetchedResultsController<T>
    }
    
    // MARK: - Create
    
    @discardableResult class func create(in context: NSManagedObjectContext) -> Self? {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: context) else { return nil }
        let object = self.init(entity: entityDescription, insertInto: context)
        return object
    }
    
    @discardableResult class func create(with attributes: [String : Any], in context: NSManagedObjectContext) -> Self? {
        guard let object = create(in: context) else { return nil }
        if !attributes.isEmpty {
            object.setValuesForKeys(attributes)
        }
        return object
    }
    
    // MARK: - Find First or Create

    class func firstOrCreate(with attribute: String, value: Any,
                             in context: NSManagedObjectContext) -> Self? {
        return _firstOrCreate(with: attribute, value: value, in: context)
    }

    private class func _firstOrCreate<T>(with attribute: String, value: Any,
                                         in context: NSManagedObjectContext) -> T? {
        let object = firstOrCreate(with: [attribute : value], in: context)
        return object as? T
    }

    class func firstOrCreate(with attributes: [String : Any],
                             predicateType: NSCompoundPredicate.LogicalType = defaultPredicateType,
                             in context: NSManagedObjectContext) -> Self? {
        return _firstOrCreate(with: attributes, predicateType: predicateType, in: context)
    }
    
    private class func _firstOrCreate<T>(with attributes: [String : Any],
                                         predicateType: NSCompoundPredicate.LogicalType = defaultPredicateType,
                                         in context: NSManagedObjectContext) -> T? {
        let predicate = createPredicate(with: attributes, predicateType: predicateType)
        let request = createFetchRequest(predicate: predicate)
        request.fetchLimit = 1
        let objects = try? context.fetch(request)
        return (objects?.first ?? create(with: attributes, in: context)) as? T
    }

    class func first(orderedBy attribute: String, ascending: Bool = true, in context: NSManagedObjectContext) -> Self? {
        let sortDescriptors = [NSSortDescriptor(key: attribute, ascending: ascending)]
        return first(orderedBy: sortDescriptors, in: context)
    }

    class func first(orderedBy sortDescriptors: [NSSortDescriptor]? = nil, in context: NSManagedObjectContext) -> Self? {
        return _first(orderedBy: sortDescriptors, in: context)
    }

    private class func _first<T>(orderedBy sortDescriptors: [NSSortDescriptor]? = nil, in context: NSManagedObjectContext) -> T? {
        let request = createFetchRequest(sortDescriptors: sortDescriptors)
        request.fetchLimit = 1
        let objects = try? context.fetch(request)
        return objects?.first as? T
    }

    class func first(with predicate: NSPredicate, orderedBy sortDescriptors: [NSSortDescriptor]? = nil, in context: NSManagedObjectContext) -> Self? {
        return _first(with: predicate, orderedBy: sortDescriptors, in: context)
    }

    private class func _first<T>(with predicate: NSPredicate, orderedBy sortDescriptors: [NSSortDescriptor]? = nil,
                                 in context: NSManagedObjectContext) -> T? {
        let request = createFetchRequest(predicate: predicate, sortDescriptors: sortDescriptors)
        request.fetchLimit = 1
        let objects = try? context.fetch(request)
        return objects?.first as? T
    }

    class func first(with attribute: String, value: Any, orderedBy sortDescriptors: [NSSortDescriptor]? = nil,
                     in context: NSManagedObjectContext) -> Self? {
        let predicate = NSPredicate(format: "%K = %@", argumentArray: [attribute, value])
        return first(with: predicate, orderedBy: sortDescriptors, in: context)
    }

    class func first(with attributes: [AnyHashable : Any], predicateType: NSCompoundPredicate.LogicalType = defaultPredicateType,
                     orderedBy sortDescriptors: [NSSortDescriptor]? = nil, in context: NSManagedObjectContext) -> Self? {
        let predicate = createPredicate(with: attributes, predicateType: predicateType)
        return first(with: predicate, orderedBy: sortDescriptors, in: context)
    }
    
    // MARK: - Find All

    class func all(orderedBy sortDescriptors: [NSSortDescriptor]? = nil, in context: NSManagedObjectContext) -> [NSManagedObject]? {
        let request = createFetchRequest(sortDescriptors: sortDescriptors)
        let objects = try? context.fetch(request)
        return objects?.isEmpty == false ? objects : nil
    }

    class func all<T>(orderedBy sortDescriptors: [NSSortDescriptor]? = nil, in context: NSManagedObjectContext) -> [T]? {
        let objects = all(orderedBy: sortDescriptors, in: context)
        return objects?.compactMap { $0 as? T }
    }

    class func all(with predicate: NSPredicate, orderedBy sortDescriptors: [NSSortDescriptor]? = nil,
                   in context: NSManagedObjectContext) -> [NSManagedObject]? {
        let request = createFetchRequest(predicate: predicate, sortDescriptors: sortDescriptors)
        let objects = try? context.fetch(request)
        return objects?.isEmpty == false ? objects : nil
    }

    class func all<T>(with predicate: NSPredicate, orderedBy sortDescriptors: [NSSortDescriptor]? = nil,
                      in context: NSManagedObjectContext) -> [T]? {
        let objects = all(with: predicate, orderedBy: sortDescriptors, in: context)
        return objects?.compactMap { $0 as? T }
    }

    class func all(with attribute: String, value: Any, orderedBy sortDescriptors: [NSSortDescriptor]? = nil,
                   in context: NSManagedObjectContext) -> [NSManagedObject]? {
        let predicate = NSPredicate(format: "%K = %@", argumentArray: [attribute, value])
        return all(with: predicate, orderedBy: sortDescriptors, in: context)
    }

    class func all<T>(with attribute: String, value: Any, orderedBy sortDescriptors: [NSSortDescriptor]? = nil,
                      in context: NSManagedObjectContext) -> [T]? {
        let objects = all(with: attribute, value: value, orderedBy: sortDescriptors, in: context)
        return objects?.compactMap { $0 as? T }
    }

    class func all(with attributes: [AnyHashable : Any], predicateType: NSCompoundPredicate.LogicalType = defaultPredicateType,
                   orderedBy sortDescriptors: [NSSortDescriptor]? = nil, in context: NSManagedObjectContext) -> [NSManagedObject]? {
        let predicate = createPredicate(with: attributes, predicateType: predicateType)
        return all(with: predicate, orderedBy: sortDescriptors, in: context)
    }

    class func all<T>(with attributes: [AnyHashable : Any], predicateType: NSCompoundPredicate.LogicalType = defaultPredicateType,
                      orderedBy sortDescriptors: [NSSortDescriptor]? = nil, in context: NSManagedObjectContext) -> [T]? {
        let objects = all(with: attributes, predicateType: predicateType, orderedBy: sortDescriptors, in: context)
        return objects?.compactMap { $0 as? T }
    }
    
    // MARK: - Delete

    func delete(from context: NSManagedObjectContext) {
        context.delete(self)
    }

    class func deleteAll(from context: NSManagedObjectContext) {
        guard let objects = all(in: context) else { return }
        objects.forEach { (object) in
            context.delete(object)
        }
    }

    class func deleteAll(with predicate: NSPredicate, from context: NSManagedObjectContext) {
        guard let objects = all(with: predicate, in: context) else { return }
        objects.forEach { (object) in
            context.delete(object)
        }
    }

    class func deleteAll(with attribute: String, value: Any, from context: NSManagedObjectContext) {
        guard let objects = all(with: attribute, value: value, in: context) else { return }
        objects.forEach { (object) in
            context.delete(object)
        }
    }

    class func deleteAll(with attributes: [AnyHashable : Any], predicateType: NSCompoundPredicate.LogicalType = defaultPredicateType,
                         from context: NSManagedObjectContext) {
        guard let objects = all(with: attributes, predicateType: predicateType, in: context) else { return }
        objects.forEach { (object) in
            context.delete(object)
        }
    }
    
    // MARK: - Count

    class func count(with predicate: NSPredicate? = nil, in context: NSManagedObjectContext) -> Int {
        let request = createFetchRequest(predicate: predicate)
        request.includesSubentities = false
        guard let count = try? context.count(for: request) else { return 0 }
        return count
    }

    class func count(with attribute: String, value: Any, in context: NSManagedObjectContext) -> Int {
        return count(with: [attribute : value], in: context)
    }

    class func count(with attributes: [AnyHashable : Any], predicateType: NSCompoundPredicate.LogicalType = defaultPredicateType,
                     in context: NSManagedObjectContext) -> Int {
        let predicate = createPredicate(with: attributes, predicateType: predicateType)
        return count(with: predicate, in: context)
    }
    
}
