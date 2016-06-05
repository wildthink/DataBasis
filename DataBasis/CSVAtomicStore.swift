//
//  CSVAtomicStore.swift
//  Pods
//
//  Created by Jason Jobe on 5/28/16.
//
//

import Cocoa


class CSVAtomicStore: NSAtomicStore {

    enum Error: ErrorType {
        case InvalidFormat
        case InaccessableURL
    }
    var dateFormatter: NSDateFormatter

    private var cache = [NSManagedObjectID: AnyObject]()
    var localStorageURL: NSURL?
    var primaryKey: String = "_id"
    var entityKey: String = "_entity"

    class var storeType: String {
        return NSStringFromClass(JSONAtomicStore.self)
    }

    override class func initialize() {
        NSPersistentStoreCoordinator.registerStoreClass(self, forStoreType:self.storeType)
    }

    override init(persistentStoreCoordinator root: NSPersistentStoreCoordinator?, configurationName name: String?, URL url: NSURL, options: [NSObject : AnyObject]?) {
        self.localStorageURL = url
        dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"

        super.init(persistentStoreCoordinator: root, configurationName: name, URL: url, options: options)
    }
    // MARK: - NSAtomicStore

    override func loadMetadata() throws {
        let uuid = NSProcessInfo.processInfo().globallyUniqueString
        self.metadata = [NSStoreTypeKey : JSONAtomicStore.storeType, NSStoreUUIDKey : uuid]
    }

    override func load() throws
    {
        guard let items = try self.loadObjectsFromJSON() else { return }
        for value in items {
            if let item = value as? [String: AnyObject] {
                cacheNodeForValues(item)
            }
        }
    }

    // MARK: - Private
    func createRelationship (relationship: NSRelationshipDescription, from subject: AnyObject, to object: AnyObject, includeInverse: Bool = true) {

        let key = relationship.name

        if relationship.toMany {
            if var rel_object = subject.valueForKey (key) as? [AnyObject] {
                rel_object.append(object)
            } else {
                subject.setValue([object], forKey: key)
            }
        } else {
            subject.setValue(object, forKey: key)
        }

        guard includeInverse else { return }

        if let inverse = relationship.inverseRelationship {
            // NOTE: includeInverse MUST be false to avoid infinite recursion
            createRelationship(inverse, from: object, to: subject, includeInverse: false)
        }
    }

    func entityNamed (name: String?) -> NSEntityDescription? {
        guard let name = name else { return nil }
        return persistentStoreCoordinator?.managedObjectModel.entitiesByName[name]
    }

    func transformValue (attribute: NSAttributeDescription, from input: AnyObject?) -> AnyObject? {

        var value: AnyObject? = nil
        guard let input = input?.description else { return nil }

        switch attribute.attributeType
        {
        case .DateAttributeType: value =  dateFormatter.dateFromString(input)
        case .StringAttributeType: value = input
        case .Integer16AttributeType: value = Int(input)
        case .Integer32AttributeType: value = Int(input)
        case .Integer64AttributeType: value = Int(input)
        case .FloatAttributeType: value = Float(input)
        case .DoubleAttributeType: value = Double(input)
        case .DecimalAttributeType: value = NSDecimalNumber(string: input, locale: nil)
        default:
            value = input
            Swift.print ("\(attribute.attributeType.rawValue) is PASS THRU")
        }
        return value
    }

    func cacheNodeForValues (values: [String: AnyObject]) -> NSAtomicStoreCacheNode?
    {
        guard let entity = entityNamed(values[entityKey] as? String) else { return nil }
        guard let referenceId = values[primaryKey] as? String else { return nil }
        let objectId = objectIDForEntity(entity, referenceObject: referenceId)

        // Make sure we avoid creating duplicates
        if let found = self.cacheNodeForObjectID(objectId) { return found }

        let node = NSAtomicStoreCacheNode(objectID: objectId)

        var nodes = Set<NSAtomicStoreCacheNode>()

        nodes.insert(node)

        for (key, attr) in entity.attributesByName {
            var value: AnyObject?
             node.setValue(value, forKey: key)
        }

        for (key, rel) in entity.relationshipsByName
        {
            if let values = values[key] as? [String: AnyObject],
                let object = cacheNodeForValues(values)
            {
                nodes.insert(object)
                createRelationship (rel, from: node, to: object)
            }
        }

        self.addCacheNodes(nodes)
        return node
    }

    /**
     Loads object data from a local JSON file

     - returns An Array of object objects in dictionary form.
     */

    func loadObjectsFromJSON() throws -> [AnyObject]? {

        guard let localStorageURL = localStorageURL else { return nil }
        guard let data = NSData(contentsOfURL: localStorageURL) else { throw Error.InvalidFormat }

        do {
            let results = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            guard let objects = results as? [NSDictionary] else {
                return nil
            }
            return objects
        }
        catch {
            throw Error.InvalidFormat
        }
    }
}
