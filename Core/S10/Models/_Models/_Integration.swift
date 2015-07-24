// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Integration.swift instead.

import CoreData

public enum IntegrationKeys: String, Printable {

    case hasError = "hasError"

    case iconUrl = "iconUrl"

    case isIndexing = "isIndexing"

    case linkedAccountName = "linkedAccountName"

    case name = "name"

    public var description: String { return rawValue }
}

@objc public
class _Integration: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Integration"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Integration.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var hasError: NSNumber?

    // func validateHasError(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var iconUrl: String?

    // func validateIconUrl(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var isIndexing: NSNumber?

    // func validateIsIndexing(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var linkedAccountName: String?

    // func validateLinkedAccountName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var name: String?

    // func validateName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

}

