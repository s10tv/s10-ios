// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Match.swift instead.

import CoreData

enum MatchAttributes: String {
    case choice = "choice"
    case dateMatched = "dateMatched"
}

enum MatchRelationships: String {
    case user = "user"
}

@objc
class _Match: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "Match"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Match.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var choice: String?

    // func validateChoice(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var dateMatched: NSDate?

    // func validateDateMatched(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var user: User?

    // func validateUser(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

