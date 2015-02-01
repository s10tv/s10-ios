// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Connection.swift instead.

import CoreData

enum ConnectionAttributes: String {
    case dateCreated = "dateCreated"
    case dateUpdated = "dateUpdated"
}

enum ConnectionRelationships: String {
    case messages = "messages"
    case user = "user"
}

@objc
class _Connection: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "Connection"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Connection.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var dateCreated: NSDate?

    // func validateDateCreated(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var dateUpdated: NSDate?

    // func validateDateUpdated(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var messages: NSSet

    @NSManaged
    var user: User?

    // func validateUser(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

extension _Connection {

    func addMessages(objects: NSSet) {
        let mutable = self.messages.mutableCopy() as NSMutableSet
        mutable.unionSet(objects)
        self.messages = mutable.copy() as NSSet
    }

    func removeMessages(objects: NSSet) {
        let mutable = self.messages.mutableCopy() as NSMutableSet
        mutable.minusSet(objects)
        self.messages = mutable.copy() as NSSet
    }

    func addMessagesObject(value: Message!) {
        let mutable = self.messages.mutableCopy() as NSMutableSet
        mutable.addObject(value)
        self.messages = mutable.copy() as NSSet
    }

    func removeMessagesObject(value: Message!) {
        let mutable = self.messages.mutableCopy() as NSMutableSet
        mutable.removeObject(value)
        self.messages = mutable.copy() as NSSet
    }

}
