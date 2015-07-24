// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ServiceType.swift instead.

import CoreData

public enum ServiceTypeKeys: String, Printable {

    case icon = "icon"

    case url = "url"

    public var description: String { return rawValue }
}

public enum ServiceTypeUserInfo: String {
    case collectionName = "collectionName"
}

@objc public
class _ServiceType: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "ServiceType"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _ServiceType.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var icon: String?

    // func validateIcon(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var url: String?

    // func validateUrl(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

}

