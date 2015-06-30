// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.swift instead.

import CoreData

public enum UserKeys: String, Printable {

    case about = "about"

    case avatarUrl = "avatarUrl"

    case coverPhotoUrl = "coverPhotoUrl"

    case createdAt = "createdAt"

    case firstName = "firstName"

    case gender = "gender"

    case lastName = "lastName"

    case candidate = "candidate"

    case connection = "connection"

    case services = "services"

    public var description: String { return rawValue }
}

@objc public
class _User: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "User"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _User.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var about: String?

    // func validateAbout(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var avatarUrl: String?

    // func validateAvatarUrl(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var coverPhotoUrl: String?

    // func validateCoverPhotoUrl(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var createdAt: NSDate?

    // func validateCreatedAt(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var firstName: String?

    // func validateFirstName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var gender: String?

    // func validateGender(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var lastName: String?

    // func validateLastName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged public
    var candidate: Candidate?

    // func validateCandidate(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var connection: Connection?

    // func validateConnection(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var services: NSSet

}

extension _User {

    func addServices(objects: NSSet) {
        let mutable = self.services.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as! Set<NSObject>)
        self.services = mutable.copy() as! NSSet
    }

    func removeServices(objects: NSSet) {
        let mutable = self.services.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as! Set<NSObject>)
        self.services = mutable.copy() as! NSSet
    }

    func addServicesObject(value: Service!) {
        let mutable = self.services.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.services = mutable.copy() as! NSSet
    }

    func removeServicesObject(value: Service!) {
        let mutable = self.services.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.services = mutable.copy() as! NSSet
    }

}

