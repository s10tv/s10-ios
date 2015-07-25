// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Activity.swift instead.

import CoreData

internal enum ActivityKeys: String, Printable {

    case caption = "caption"

    case image_ = "image_"

    case profileId = "profileId"

    case text = "text"

    case timestamp = "timestamp"

    case type_ = "type_"

    case url_ = "url_"

    case user = "user"

    internal var description: String { return rawValue }
}

@objc internal
class _Activity: NSManagedObject {

    // MARK: - Class methods

    internal class func entityName () -> String {
        return "Activity"
    }

    internal class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    internal override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    internal convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Activity.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged internal
    var caption: String?

    // func validateCaption(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged internal
    var image_: AnyObject?

    // func validateImage_(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged internal
    var profileId: String

    // func validateProfileId(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged internal
    var text: String?

    // func validateText(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged internal
    var timestamp: NSDate

    // func validateTimestamp(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged internal
    var type_: String

    // func validateType_(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged internal
    var url_: String?

    // func validateUrl_(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged internal
    var user: User?

    // func validateUser(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

