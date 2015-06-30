// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Video.swift instead.

import CoreData

public enum VideoKeys: String, Printable {

    case coverFrameUrl = "coverFrameUrl"

    case createdAt = "createdAt"

    case url = "url"

    case message = "message"

    public var description: String { return rawValue }
}

@objc public
class _Video: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Video"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Video.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var coverFrameUrl: String?

    // func validateCoverFrameUrl(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var createdAt: NSDate?

    // func validateCreatedAt(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var url: String?

    // func validateUrl(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged public
    var message: Message?

    // func validateMessage(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

