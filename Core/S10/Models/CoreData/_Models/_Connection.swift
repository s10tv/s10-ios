// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Connection.swift instead.

import CoreData

internal enum ConnectionKeys: String, CustomStringConvertible {

    case lastMessageStatus_ = "lastMessageStatus_"

    case thumbnail_ = "thumbnail_"

    case title = "title"

    case unreadCount = "unreadCount"

    case updatedAt = "updatedAt"

    case lastSender = "lastSender"

    case otherUser = "otherUser"

    internal var description: String { return rawValue }
}

@objc internal
class _Connection: NSManagedObject {

    // MARK: - Class methods

    internal class func entityName () -> String {
        return "Connection"
    }

    internal class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    internal override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    internal convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Connection.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged internal
    var lastMessageStatus_: String?

    // func validateLastMessageStatus_(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged internal
    var thumbnail_: AnyObject

    // func validateThumbnail_(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged internal
    var title: String

    // func validateTitle(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged internal
    var unreadCount: NSNumber?

    // func validateUnreadCount(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged internal
    var updatedAt: NSDate

    // func validateUpdatedAt(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged internal
    var lastSender: User?

    // func validateLastSender(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged internal
    var otherUser: User

    // func validateOtherUser(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

