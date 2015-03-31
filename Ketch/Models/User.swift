//
//  User.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/20/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import Meteor
import JSQMessagesViewController
import SDWebImage

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
        return documentID == Core.meteor.userID
    }
    
    var photos : [Photo]? {
        if let urls = photoURLs as? [NSString] {
            return urls.map { Photo(url: $0) }
        }
        return nil
    }
    
    var infoItems : [ProfileInfoItem] {
        var items = [ProfileInfoItem]()

        if location != nil {
            items.append(ProfileInfoItem(type: .Location, text: location!))
        }
        if age != nil { // TODO: Make this birthday, not age
            items.append(ProfileInfoItem(type: .Age, text: toString(age!)))
        }
        if height != nil { // TODO: Format feet and inches
            items.append(ProfileInfoItem(type: .Height, text: "\(height!)cm"))
        }
        if work != nil {
            items.append(ProfileInfoItem(type: .Work, text: work!))
        }
        if education != nil {
            items.append(ProfileInfoItem(type: .Education, text: education!))
        }
        
        return items
    }
    
    var profilePhotoURL : NSURL? {
        let firstPhotoUrl = photos?.first?.url
        return firstPhotoUrl != nil ? NSURL(string: firstPhotoUrl!) : nil
    }
    
    var displayName : String {
        return firstName != nil ? (lastName != nil ? "\(firstName!) \(lastName!)" : firstName!) : ""
    }
    
    func jsqAvatar() -> JSQMessagesAvatarImage {
        // TODO: Add gender to user
        let image = JSQMessagesAvatarImage(placeholder: UIImage(named: R.ImagesAssets.girlPlaceholder))
        let key = SDWebImageManager.sharedManager().cacheKeyForURL(self.profilePhotoURL)
        image.avatarImage = SDImageCache.sharedImageCache().imageFromDiskCacheForKey(key)
        return image
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
