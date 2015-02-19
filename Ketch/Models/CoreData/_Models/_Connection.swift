// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Connection.swift instead.

import CoreData

enum ConnectionAttributes: String {
    case dateCreated = "dateCreated"
    case dateUpdated = "dateUpdated"
    case expiryDate = "expiryDate"
    case lastMessageText = "lastMessageText"
    case type = "type"
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
    var dateCreated: NSDate?

    // func validateDateCreated(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var dateUpdated: NSDate?

    // func validateDateUpdated(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var expiryDate: NSDate?

    // func validateExpiryDate(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var lastMessageText: String?

    // func validateLastMessageText(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var type: String?

    // func validateType(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var user: User?

    // func validateUser(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

