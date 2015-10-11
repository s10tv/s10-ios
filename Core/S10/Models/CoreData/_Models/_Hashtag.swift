// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Hashtag.swift instead.

import CoreData

internal enum HashtagKeys: String, CustomStringConvertible {

    case selected = "selected"

    case text = "text"

    internal var description: String { return rawValue }
}

@objc internal
class _Hashtag: NSManagedObject {

    // MARK: - Class methods

    internal class func entityName () -> String {
        return "Hashtag"
    }

    internal class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    internal override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    internal convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Hashtag.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged internal
    var selected: NSNumber?

    // func validateSelected(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged internal
    var text: String

    // func validateText(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

}

