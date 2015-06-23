//
//  User.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/20/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import Meteor
import Bond

@objc(User)
public class User: _User {
    
    public enum Gender : String {
        case Male = "male"
        case Female = "female"
    }
    
    
    public private(set) lazy var dynAvatarURL: Dynamic<NSURL> = {
        return dynamicObservableFor(self, keyPath: UserAttributes.avatarUrl.rawValue, defaultValue: "").map { NSURL($0) }
    }()
    
    public private(set) lazy var dynFirstName: Dynamic<String> = {
        return dynamicObservableFor(self, keyPath: UserAttributes.firstName.rawValue, defaultValue: "")
    }()
    
    public private(set) lazy var dynLastName: Dynamic<String> = {
        return dynamicObservableFor(self, keyPath: UserAttributes.lastName.rawValue, defaultValue: "")
    }()
    
    public private(set) lazy var dynDisplayName: Dynamic<String> = {
        return reduce(self.dynFirstName, self.dynLastName) { "\($0) \($1)".nonBlank() ?? "" }
    }()
    
    
    public var avatarURL : NSURL? {
        return avatarUrl.map { NSURL($0) } ?? nil
    }
    
    public var displayName : String {
        return firstName != nil ? (lastName != nil ? "\(firstName!) \(lastName!)" : firstName!) : ""
    }
    
    public func connection() -> Connection? {
        return fetchConnection().fetchObjects().first as? Connection
    }
    
    public func fetchConnection() -> NSFetchedResultsController {
        return Connection.by(ConnectionRelationships.otherUser.rawValue, value: self).frc()
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
