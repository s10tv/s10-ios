//
//  User.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/20/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import Meteor

@objc(User)
class User: _User {
    
    var photos : [Photo]? {
        get {
            if let urls = photoURLs as? [NSString] {
                return urls.map { Photo(url: $0) }
            }
            return nil
        }
    }
    
    var profilePhotoURL : NSURL? {
        let firstPhotoUrl = photos?.first?.url
        return firstPhotoUrl != nil ? NSURL(string: firstPhotoUrl!) : nil
    }
    
    override func awakeFromFetch() {
        super.awakeFromFetch()
        
        // TODO: Remove placeholders values when server provides them
        let age = (19...28).map { $0 }.randomElement()
        self.age = age
        self.location = [
            "San Francisco, CA",
            "Mountain View, CA",
            "Palo Alto, CA",
            "Menlo Park, CA",
            "Sausalito, CA",
            "San Mateo, CA",
            "Cupertino, CA",
            "Sunnyvale, CA",
            "Berkeley, CA"
        ].randomElement()
    }

    func makeConnection() {
        if connection != nil { return }
        connection = Connection.MR_createInContext(self.managedObjectContext) as? Connection
    }
    
    // TODO: Obviously incorrect. Fix so we have real reference to currentUser
    class func currentUser() -> User {
        let key = METDocumentKey(collectionName: "users", documentID: Core.meteor.userID)
        let userObjectID = Core.meteor.objectIDForDocumentKey(key)
        println("userid \(key.documentID) objectid \(userObjectID)")
        return Core.meteor.mainQueueManagedObjectContext.objectWithID(userObjectID) as User
    }
}

class Photo {
    let url: String
    
    init(url: String) {
        self.url = url
    }
}

class PhotosValueTransformer : NSValueTransformer {
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        let photos = value as [Photo]
        return photos.map { $0.url }
    }
    
    override func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
        let urls = value as [String]
        return urls.map { Photo(url: $0) }
    }
}