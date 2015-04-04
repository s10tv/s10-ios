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
        let items : [(ProfileInfoItem.ItemType, Any?)] = [
            (.Location, location),
            (.Age, age),
            (.Height, height),
            (.Work, work),
            (.Education, education)
        ]
        return items.mapOptional { (type, value) -> ProfileInfoItem? in
            value != nil ? ProfileInfoItem(type: type, value: value!) : nil
        }
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
        if let currentUserID = Core.meteor.userID {
            return findByDocumentID(currentUserID)
        }
        return nil
    }
}

class Photo {
    let url: String
    
    init(url: String) {
        self.url = url
    }
}

class ProfileInfoItem {
    enum ItemType {
        case Location, Age, Height, Work, Education
    }
    let type : ItemType
    let value : Any
    let imageName : String
    let minWidthRatio : CGFloat = 1
    
    var image : UIImage! {
        return UIImage(named: imageName)
    }
    
    var text : String {
        struct formatters {
            static let height : NSLengthFormatter = {
                let formatter = NSLengthFormatter()
                formatter.forPersonHeightUse = true
                formatter.unitStyle = .Short
                formatter.numberFormatter.maximumFractionDigits = 0
                return formatter
            }()
        }
        
        switch type {
            case .Location: return value as String
            case .Age: return toString(value as Int)
            case .Height: return formatters.height.stringFromMeters(Double(value as Int) / 100)
            case .Work: return value as String
            case .Education: return value as String
        }
    }
    
    init(type: ItemType, value: Any) {
        self.type = type
        self.value = value
        switch type {
        case .Location:
            imageName = R.ImagesAssets.settingsLocation
        case .Age:
            imageName = R.ImagesAssets.settingsAge
            minWidthRatio = 0.5
        case .Height:
            imageName = R.ImagesAssets.settingsHeightArrow
            minWidthRatio = 0.5
        case .Work:
            imageName = R.ImagesAssets.settingsBriefcase
        case .Education:
            imageName = R.ImagesAssets.settingsMortarBoard
        }
    }
    
}