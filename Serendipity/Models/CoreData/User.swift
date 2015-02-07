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

    func makeConnection() {
        if connection != nil { return }
        connection = Connection.MR_createInContext(self.managedObjectContext) as? Connection
    }
    
    class func findByDocumentID(documentID: String) -> User? {
        return Core.mainContext.objectInCollection("users", documentID: documentID) as? User
    }
    
    class func currentUser() -> User? {
        return findByDocumentID(Core.meteor.userID)
    }
}

class Photo {
    let url: String
    
    init(url: String) {
        self.url = url
    }
}
