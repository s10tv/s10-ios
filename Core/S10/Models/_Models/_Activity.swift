// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Activity.swift instead.

import CoreData

public enum ActivityKeys: String, Printable {

    case action = "action"

    case caption = "caption"

    case imageUrl = "imageUrl"

    case text = "text"

    case timestamp = "timestamp"

    case videoUrl = "videoUrl"

    case service = "service"

    case user = "user"

    public var description: String { return rawValue }
}

@objc public
class _Activity: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Activity"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Activity.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var action: String?

    // func validateAction(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var caption: String?

    // func validateCaption(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var imageUrl: String?

    // func validateImageUrl(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var text: String?

    // func validateText(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var timestamp: NSDate?

    // func validateTimestamp(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var videoUrl: String?

    // func validateVideoUrl(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged public
    var service: Service?

    // func validateService(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var user: User?

    // func validateUser(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

