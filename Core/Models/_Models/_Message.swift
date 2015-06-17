// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Message.swift instead.

import CoreData

public enum MessageAttributes: String {
    case createdAt = "createdAt"
    case expiresAt = "expiresAt"
    case status = "status"
}

public enum MessageRelationships: String {
    case connection = "connection"
    case sender = "sender"
    case video = "video"
}

@objc public
class _Message: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Message"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Message.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var createdAt: NSDate?

    // func validateCreatedAt(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var expiresAt: NSDate?

    // func validateExpiresAt(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var status: String?

    // func validateStatus(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged public
    var connection: Connection?

    // func validateConnection(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var sender: User?

    // func validateSender(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var video: Video?

    // func validateVideo(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

