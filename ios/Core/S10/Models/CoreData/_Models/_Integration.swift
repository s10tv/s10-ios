// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Integration.swift instead.

import CoreData

internal enum IntegrationKeys: String, CustomStringConvertible {

    case icon_ = "icon_"

    case name = "name"

    case status_ = "status_"

    case updatedAt = "updatedAt"

    case url_ = "url_"

    case username = "username"

    internal var description: String { return rawValue }
}

@objc internal
class _Integration: NSManagedObject {

    // MARK: - Class methods

    internal class func entityName () -> String {
        return "Integration"
    }

    internal class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    internal override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    internal convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Integration.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged internal
    var icon_: AnyObject

    // func validateIcon_(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged internal
    var name: String

    // func validateName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged internal
    var status_: String

    // func validateStatus_(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged internal
    var updatedAt: NSDate?

    // func validateUpdatedAt(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged internal
    var url_: String

    // func validateUrl_(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged internal
    var username: String?

    // func validateUsername(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

}

