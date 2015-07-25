// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Message.swift instead.

import CoreData

internal enum MessageKeys: String, Printable {

    case createdAt = "createdAt"

    case expiresAt = "expiresAt"

    case status_ = "status_"

    case video_ = "video_"

    case connection = "connection"

    case sender = "sender"

    internal var description: String { return rawValue }
}

@objc internal
class _Message: NSManagedObject {

    // MARK: - Class methods

    internal class func entityName () -> String {
        return "Message"
    }

    internal class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    internal override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    internal convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Message.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged internal
    var createdAt: NSDate

    // func validateCreatedAt(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged internal
    var expiresAt: NSDate?

    // func validateExpiresAt(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged internal
    var status_: String

    // func validateStatus_(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged internal
    var video_: AnyObject

    // func validateVideo_(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged internal
    var connection: Connection

    // func validateConnection(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged internal
    var sender: User

    // func validateSender(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

