// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Candidate.swift instead.

import CoreData

enum CandidateAttributes: String {
    case choice = "choice"
    case dateMatched = "dateMatched"
}

enum CandidateRelationships: String {
    case user = "user"
}

enum CandidateUserInfo: String {
    case collectionName = "collectionName"
}

@objc
class _Candidate: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "Candidate"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Candidate.entity(managedObjectContext)
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

