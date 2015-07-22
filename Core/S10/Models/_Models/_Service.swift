// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Service.swift instead.

import CoreData

public enum ServiceKeys: String, Printable {

    case avatar = "avatar"

    case userDisplayName = "userDisplayName"

    case userIdentifier = "userIdentifier"

    case serviceType = "serviceType"

    case user = "user"

    public var description: String { return rawValue }
}

@objc public
class _Service: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Service"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Service.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var avatar: String?

    // func validateAvatar(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var userDisplayName: String?

    // func validateUserDisplayName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var userIdentifier: String?

    // func validateUserIdentifier(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged public
    var serviceType: ServiceType?

    // func validateServiceType(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var user: User?

    // func validateUser(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

