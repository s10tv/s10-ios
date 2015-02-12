// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Message.swift instead.

import CoreData

enum MessageAttributes: String {
    case isUnread = "isUnread"
    case text = "text"
    case thumbnailURL = "thumbnailURL"
    case timestamp = "timestamp"
    case videoURL = "videoURL"
}

enum MessageRelationships: String {
    case connection = "connection"
    case sender = "sender"
}

@objc
class _Message: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "Message"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Message.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var isUnread: NSNumber?

    // func validateIsUnread(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var text: String?

    // func validateText(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var thumbnailURL: String?

    // func validateThumbnailURL(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var timestamp: NSDate?

    // func validateTimestamp(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var videoURL: String?

    // func validateVideoURL(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var connection: Connection?

    // func validateConnection(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var sender: User?

    // func validateSender(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

