// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Message.swift instead.

import CoreData

enum MessageAttributes: String {
    case createdAt = "createdAt"
    case expiresAt = "expiresAt"
    case status = "status"
}

enum MessageRelationships: String {
    case conversation = "conversation"
    case sender = "sender"
    case video = "video"
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
    var createdAt: NSDate?

    // func validateCreatedAt(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var expiresAt: NSDate?

    // func validateExpiresAt(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var status: String?

    // func validateStatus(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var conversation: Conversation?

    // func validateConversation(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var sender: User?

    // func validateSender(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var video: Video?

    // func validateVideo(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

