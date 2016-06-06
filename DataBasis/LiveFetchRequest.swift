//
//  LiveFetchRequest.swift
//  Pods
//
//  Created by Jason Jobe on 6/5/16.
//
//

import CoreData

@objc protocol LiveFetchRequestDelegate {

    func fetchRequest (liveFetchRequest: LiveFetchRequest, didInsert: [AnyObject])
    func fetchRequest (liveFetchRequest: LiveFetchRequest, didDelete: [AnyObject])
    func fetchRequest (liveFetchRequest: LiveFetchRequest, didUpdate: [AnyObject])
}


public class LiveFetchRequest: NSObject {

    var fetchRequest: NSFetchRequest!
    var manangedObjectContext: NSManagedObjectContext!
    var delegate: LiveFetchRequestDelegate?

    public init (fetch: NSFetchRequest, managedObjectContext: NSManagedObjectContext) {
        self.fetchRequest = fetch
        self.manangedObjectContext = managedObjectContext
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func performFetch() throws {

        NSNotificationCenter.defaultCenter().addObserver(self,
                selector: #selector(managedObjectContextObjectsDidChange),
                    name: NSManagedObjectContextObjectsDidChangeNotification,
                  object: manangedObjectContext)

        try manangedObjectContext.executeRequest(fetchRequest)
    }

    func managedObjectContextObjectsDidChange(notification: NSNotification)
    {
        guard let delegate = delegate else { return }

        if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? [AnyObject] {
            let objects = insertedObjects.filter ({ (any: AnyObject) in self.fetchRequest.matches(any) })
            if !objects.isEmpty {
                delegate.fetchRequest(self, didInsert: objects)
            }
        }

        if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? [AnyObject] {
            let objects = deletedObjects.filter ({ (any: AnyObject) in self.fetchRequest.matches(any) })
            if !objects.isEmpty {
                delegate.fetchRequest(self, didInsert: objects)
            }
        }

        if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? [AnyObject] {
            let objects = updatedObjects.filter ({ (any: AnyObject) in self.fetchRequest.matches(any) })
            if !objects.isEmpty {
                delegate.fetchRequest(self, didUpdate: objects)
            }
        }
    }
}


extension NSFetchRequest {

    func matches (object: AnyObject?) -> Bool {
        guard let object = object else { return false }

        if let c: AnyClass = NSClassFromString(self.entity?.className ?? "") {
            if object.isMemberOfClass(c) {
                return self.predicate?.evaluateWithObject(object) ?? true
            }
        }
        return false
    }
}