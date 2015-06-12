// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Post.swift instead.

import CoreData

enum PostAttributes: String {
    case createdAt = "createdAt"
    case location = "location"
    case score = "score"
    case upvotes = "upvotes"
}

enum PostRelationships: String {
    case author = "author"
    case video = "video"
}

@objc
class _Post: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "Post"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Post.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var createdAt: NSDate?

    // func validateCreatedAt(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var location: AnyObject?

    // func validateLocation(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var score: NSNumber?

    // func validateScore(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var upvotes: NSNumber?

    // func validateUpvotes(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var author: User?

    // func validateAuthor(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var video: Video?

    // func validateVideo(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

