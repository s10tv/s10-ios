//
//  LayerHelpers.swift
//  S10
//
//  Created by Tony Xiao on 10/15/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import LayerKit

let lyrTopic = "topic"
let lyrAvatarUrl = "avatarUrl"

func lyrUserAvatarUrl(userId: String) -> String {
    return "users_\(userId)_avatarUrl"
}
func lyrUserDisplayName(userId: String) -> String {
    return "users_\(userId)_displayName"
}

extension LYRConversation {
    var topic: String? {
        get { return metadata[lyrTopic] as? String }
        set { setValue(newValue, forMetadataAtKeyPath: lyrTopic) }
    }
    
    var avatarURL: NSURL? {
        get { return (metadata[lyrAvatarUrl] as? String).flatMap { NSURL(string: $0) } }
        set { setValue(newValue, forMetadataAtKeyPath: lyrAvatarUrl) }
    }

    // TODO: currentUserId should probably not be nil?
    func recipientId(currentUserId: String?) -> String? {
        let others = participants.filter { $0 != currentUserId }
        return others.first as? String
    }
    
    func recipient(context: NSManagedObjectContext, currentUserId: String?) -> User? {
        let others = participants.filter { $0 != currentUserId }
        if let userId = others.first as? String {
            return context.existingObjectInCollection("users", documentID: userId) as? User
        }
        return nil
    }
    
    func getUserAvatarURL(userId: String) -> NSURL? {
        return (metadata[lyrUserAvatarUrl(userId)] as? String).flatMap { NSURL(string: $0) }
    }
    
    func setUserAvatarURL(userId: String, url: NSURL) {
        setValue(url.absoluteString, forMetadataAtKeyPath: lyrUserAvatarUrl(userId))
    }
    
    func getUserDisplayName(userId: String) -> String? {
        return metadata[lyrUserDisplayName(userId)] as? String
    }
    
    func setUserDisplayName(userID: String, displayName: String) {
        setValue(displayName, forMetadataAtKeyPath: lyrUserDisplayName(userID))
    }
}
