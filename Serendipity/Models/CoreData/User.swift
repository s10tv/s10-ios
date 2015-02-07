//
//  User.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/20/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

@objc(User)
class User: _User {
    
    var profilePhotoURL : NSURL? {
        let firstPhotoUrl = (photos as? [Photo])?.first?.url
        return firstPhotoUrl != nil ? NSURL(string: firstPhotoUrl!) : nil
    }

    func makeConnection() {
        if connection != nil { return }
        connection = Connection.MR_createInContext(self.managedObjectContext) as? Connection
    }
    
    // TODO: Obviously incorrect. Fix so we have real reference to currentUser
    class func currentUser() -> User {
        return self.MR_findFirst() as User!
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
        let photos = value as Array<Photo>
        let urls = photos.map { $0.url }
        return NSJSONSerialization.dataWithJSONObject(urls, options: nil, error: nil)
    }
    
    override func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
        let urls = NSJSONSerialization.JSONObjectWithData(value as NSData, options: nil, error: nil) as Array<String>
        return urls.map { Photo(url: $0) }
    }
}