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
public class User: _User {
    
    public enum Gender : String {
        case Male = "male"
        case Female = "female"
    }
    
    public var avatarURL : NSURL? {
        return avatarUrl.map { NSURL($0) } ?? nil
    }
    
    public var displayName : String {
        return firstName != nil ? (lastName != nil ? "\(firstName!) \(lastName!)" : firstName!) : ""
    }
    
    public override class func keyPathsForValuesAffectingValueForKey(key: String) -> Set<NSObject> {
        if key == "displayName" {  // TODO: Use native set syntax. TODO: Can we avoid hardcoding displayName?
            return [UserAttributes.firstName.rawValue, UserAttributes.lastName.rawValue]
        }
        return super.keyPathsForValuesAffectingValueForKey(key)
    }
    
    public class func findByDocumentID(context: NSManagedObjectContext, documentID: String) -> User? {
        return context.objectInCollection("users", documentID: documentID) as? User
    }
    
}
