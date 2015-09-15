// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Candidate.swift instead.

import CoreData

internal enum CandidateKeys: String, Printable {

    case date = "date"

    case reason = "reason"

    case status_ = "status_"

    case user = "user"

    internal var description: String { return rawValue }
}

@objc internal
class _Candidate: NSManagedObject {

    // MARK: - Class methods

    internal class func entityName () -> String {
        return "Candidate"
    }

    internal class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    internal override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    internal convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Candidate.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged internal
    var date: NSDate

    // func validateDate(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged internal
    var reason: String

    // func validateReason(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged internal
    var status_: String

    // func validateStatus_(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged internal
    var user: User

    // func validateUser(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

