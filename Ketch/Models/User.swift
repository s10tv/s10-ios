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
    
    var connection : Connection? {
        return fetchConnection().fetchObjects().first as? Connection
    }
    var candidate : Candidate? {
        return fetchCandidate().fetchObjects().first as? Candidate
    }
    
    var isCurrentUser : Bool {
        return documentID == Meteor.userID
    }
    
    var photos : [Photo]? {
        if let urls = photoURLs as? [NSString] {
            return urls.map { Photo(url: $0) }
        }
        return nil
    }
    
    var infoItems : [ProfileInfoItem] {
        let items : [ProfileInfoItem.ItemType?] = [
            location.map { .Location($0) },
            (age as? Int).map { .Age($0) },
            (height as? Int).map { .Height($0) },
            work.map { .Work($0) },
            education.map { .Education($0) }
        ]
        return items.mapOptional { $0.map { ProfileInfoItem($0) } }
    }
    
    var profilePhotoURL : NSURL? {
        let firstPhotoUrl = photos?.first?.url
        return firstPhotoUrl != nil ? NSURL(string: firstPhotoUrl!) : nil
    }
    
    var displayName : String {
        return firstName != nil ? (lastName != nil ? "\(firstName!) \(lastName!)" : firstName!) : ""
    }
        
    func fetchConnection() -> NSFetchedResultsController {
        return Connection.by(ConnectionRelationships.user.rawValue, value: self).frc()
    }
    
    func fetchCandidate() -> NSFetchedResultsController {
        return Candidate.by(CandidateRelationships.user.rawValue, value: self).frc()
    }
    
    override class func keyPathsForValuesAffectingValueForKey(key: String) -> NSSet {
        if key == "displayName" {  // TODO: Use native set syntax. TODO: Can we avoid hardcoding displayName?
            return NSSet(array: [UserAttributes.firstName.rawValue, UserAttributes.lastName.rawValue])
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

struct Photo {
    let url: String
    
    init(url: String) {
        self.url = url
    }
}
