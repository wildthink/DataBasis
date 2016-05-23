//
//  StoreBasis.swift
//  DataBasis
//
//  Created by Jason Jobe on 5/21/16.
//  Copyright © 2016 WildThink. All rights reserved.
//

import Cocoa
import CoreData

class StoreBasis: NSObject {

    static let sharedManager = StoreBasis()
    var cacheURL: NSURL!
    var modelURL = NSBundle.mainBundle().URLForResource("Palettes", withExtension: "momd")!
    override init() {
        super.init()
    }

    // MARK: - Core Data stack

    lazy var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }

        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return managedObjectContext
    }()

    // MARK: - Public
#if !os(OSX)

    func fetchedResultsControllerForEntityName(name:String, sortDescriptors:Array<NSSortDescriptor>, predicate:NSPredicate! = nil) -> NSFetchedResultsController {
        let managedObjectContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: managedObjectContext!)

        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 20
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate

        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)

        do {
            try fetchedResultsController.performFetch()
        }
        catch (let error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            print("Unresolved error: \(error)")
            abort()
        }

        return fetchedResultsController;
    }
#endif

    // MARK: - Private

    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        let storeType = JSONAtomicStore.storeType

        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.cacheURL.URLByAppendingPathComponent("backup.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."

        let options = [NSMigratePersistentStoresAutomaticallyOption: NSNumber(bool: true), NSInferMappingModelAutomaticallyOption: NSNumber(bool: true)];

        do {
            try coordinator!.addPersistentStoreWithType(storeType, configuration: nil, URL: url, options: options)
        }
        catch (let error as NSError) {
            if error.code == NSMigrationMissingMappingModelError {
                print("Error, migration failed. Delete model at \(url)")
            }
            else {
                print("Error creating persistent store: \(error.description)")
            }
            abort()
        }
        
        return coordinator
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        return NSManagedObjectModel(contentsOfURL: self.modelURL)!
    }()
}
