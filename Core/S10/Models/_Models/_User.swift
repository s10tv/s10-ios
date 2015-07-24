// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.swift instead.

import CoreData

public enum UserKeys: String, Printable {

    case about = "about"

    case avatar = "avatar"

    case candidateScore = "candidateScore"

    case connectedProfiles = "connectedProfiles"

    case cover = "cover"

    case createdAt = "createdAt"

    case distance = "distance"

    case employer = "employer"

    case firstName = "firstName"

    case jobTitle = "jobTitle"

    case lastActive = "lastActive"

    case lastName = "lastName"

    case username = "username"

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
    var avatar: AnyObject?

    // func validateAvatar(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var candidateScore: NSNumber?

    // func validateCandidateScore(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var connectedProfiles: AnyObject?

    // func validateConnectedProfiles(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var cover: AnyObject?

    // func validateCover(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var createdAt: NSDate?

    // func validateCreatedAt(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var distance: NSNumber?

    // func validateDistance(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var employer: String?

    // func validateEmployer(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var firstName: String?

    // func validateFirstName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var jobTitle: String?

    // func validateJobTitle(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var lastActive: NSDate?

    // func validateLastActive(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var lastName: String?

    // func validateLastName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged public
    var username: String?

    // func validateUsername(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

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

