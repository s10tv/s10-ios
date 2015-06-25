// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Connection.swift instead.

import CoreData

public enum ConnectionKeys: String, Printable {

    case createdAt = "createdAt"

    case lastMessageStatus = "lastMessageStatus"

    case unreadCount = "unreadCount"

    case updatedAt = "updatedAt"

    case lastSender = "lastSender"

    case otherUser = "otherUser"

    public var description: String { return rawValue }
}

@objc public
class _Connection: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Connection"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Connection.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var createdAt: NSDate?

    // func validateCreatedAt(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var lastMessageStatus: String?

    // func validateLastMessageStatus(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var unreadCount: NSNumber?

    // func validateUnreadCount(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var updatedAt: NSDate?

    // func validateUpdatedAt(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged public
    var lastSender: User?

    // func validateLastSender(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var otherUser: User?

    // func validateOtherUser(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

