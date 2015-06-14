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
    
    enum Gender : String {
        case Male = "male"
        case Female = "female"
    }
    
    var isCurrentUser : Bool {
        return documentID == Meteor.userID
    }
    
    var infoItems : [ProfileInfoItem] {
        return []
    }
    
    var avatarURL : NSURL? {
        return avatarUrl.map { NSURL($0) } ?? nil
    }
    
    var displayName : String {
        return firstName != nil ? (lastName != nil ? "\(firstName!) \(lastName!)" : firstName!) : ""
    }
    
    override class func keyPathsForValuesAffectingValueForKey(key: String) -> Set<NSObject> {
        if key == "displayName" {  // TODO: Use native set syntax. TODO: Can we avoid hardcoding displayName?
            return [UserAttributes.firstName.rawValue, UserAttributes.lastName.rawValue]
        }
        return super.keyPathsForValuesAffectingValueForKey(key)
    }
    
    class func findByDocumentID(documentID: String) -> User? {
        return Meteor.mainContext.objectInCollection("users", documentID: documentID) as? User
    }
    
    class func currentUser() -> User? {
        if let currentUserID = Meteor.userID {
            return findByDocumentID(currentUserID)
        }
        return nil
    }
}
