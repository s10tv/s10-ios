// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Conversation.swift instead.

import CoreData

enum ConversationAttributes: String {
    case createdAt = "createdAt"
    case unreadCount = "unreadCount"
    case updatedAt = "updatedAt"
}

enum ConversationRelationships: String {
    case otherUser = "otherUser"
}

@objc
class _Conversation: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "Conversation"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Conversation.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var createdAt: NSDate?

    // func validateCreatedAt(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var unreadCount: NSNumber?

    // func validateUnreadCount(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var updatedAt: NSDate?

    // func validateUpdatedAt(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var otherUser: User?

    // func validateOtherUser(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

