// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Connection.swift instead.

import CoreData

enum ConnectionAttributes: String {
    case createdAt = "createdAt"
    case expiresAt = "expiresAt"
    case hasUnreadMessage = "hasUnreadMessage"
    case lastMessageText = "lastMessageText"
    case type = "type"
    case updatedAt = "updatedAt"
}

enum ConnectionRelationships: String {
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
    var createdAt: NSDate?

    // func validateCreatedAt(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var expiresAt: NSDate?

    // func validateExpiresAt(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var hasUnreadMessage: NSNumber?

    // func validateHasUnreadMessage(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var lastMessageText: String?

    // func validateLastMessageText(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var type: String?

    // func validateType(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var updatedAt: NSDate?

    // func validateUpdatedAt(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var user: User?

    // func validateUser(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

