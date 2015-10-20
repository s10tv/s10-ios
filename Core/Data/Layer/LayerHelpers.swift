//
//  LayerHelpers.swift
//  S10
//
//  Created by Tony Xiao on 10/15/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import LayerKit

let lyrTitle = "title"
let lyrAvatarUrl = "avatarUrl"
let lyrCoverUrl = "coverUrl"

func lyrUserAvatarUrl(userId: String) -> String {
    return "users_\(userId)_avatarUrl"
}
func lyrUserCoverUrl(userId: String) -> String {
    return "users_\(userId)_coverUrl"
}
func lyrUserDisplayName(userId: String) -> String {
    return "users_\(userId)_displayName"
}

extension LYRConversation {
    var title: String? {
        get { return metadata[lyrTitle] as? String }
        set { setValue(newValue, forMetadataAtKeyPath: lyrTitle) }
    }
    
    var avatarURL: NSURL? {
        get { return (metadata[lyrAvatarUrl] as? String).flatMap { NSURL(string: $0) } }
        set { setValue(newValue, forMetadataAtKeyPath: lyrAvatarUrl) }
    }
    
    var coverURL: NSURL? {
        get { return (metadata[lyrCoverUrl] as? String).flatMap { NSURL(string: $0) } }
        set { setValue(newValue, forMetadataAtKeyPath: lyrCoverUrl) }
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
    
    func getUserCoverURL(userId: String) -> NSURL? {
        return (metadata[lyrUserCoverUrl(userId)] as? String).flatMap { NSURL(string: $0) }
    }
    
    func setUserCoverURL(userId: String, url: NSURL) {
        setValue(url.absoluteString, forMetadataAtKeyPath: lyrUserCoverUrl(userId))
    }
    
    func getUserDisplayName(userId: String) -> String? {
        return metadata[lyrUserDisplayName(userId)] as? String
    }
    
    func setUserDisplayName(userID: String, displayName: String) {
        setValue(displayName, forMetadataAtKeyPath: lyrUserDisplayName(userID))
    }
}

// MARK: - Conversation Messages

extension LYRQuery {
    static func transferingMessages(conversation: LYRConversation? = nil) -> LYRQuery {
        let query = LYRQuery(queryableClass: LYRMessage.self)
        let statuses: [LYRContentTransferStatus] = [.AwaitingUpload, .Uploading, .Downloading]
        var predicates = [
            LYRPredicate(property: "parts.MIMEType", predicateOperator: .IsEqualTo, value: kMIMETypeVideo),
            LYRPredicate(property: "parts.transferStatus", predicateOperator: .IsIn, value: statuses.map { $0.rawValue }),
        ]
        if let conversation = conversation {
            predicates.append(LYRPredicate(property: "conversation", predicateOperator: .IsEqualTo, value: conversation))
        }
        query.predicate = LYRCompoundPredicate(type: .And, subpredicates: predicates)
        return query
    }
    
    static func uploadingMessages(conversation: LYRConversation? = nil) -> LYRQuery {
        let query = LYRQuery(queryableClass: LYRMessage.self)
        let statuses = [LYRContentTransferStatus.AwaitingUpload.rawValue, LYRContentTransferStatus.Uploading.rawValue]
        var predicates = [
            LYRPredicate(property: "parts.MIMEType", predicateOperator: .IsEqualTo, value: kMIMETypeVideo),
            LYRPredicate(property: "parts.transferStatus", predicateOperator: .IsIn, value: statuses),
            //            LYRPredicate(property: "sender.userID", predicateOperator: .IsEqualTo, value: userId),
        ]
        if let conversation = conversation {
            predicates.append(LYRPredicate(property: "conversation", predicateOperator: .IsEqualTo, value: conversation))
        }
        query.predicate = LYRCompoundPredicate(type: .And, subpredicates: predicates)
        return query
    }
    
    static func downloadingMessages(conversation: LYRConversation? = nil) -> LYRQuery {
        let query = LYRQuery(queryableClass: LYRMessage.self)
        let statuses = [LYRContentTransferStatus.Downloading.rawValue] // Do not include ReadyToDownload for now
        var predicates = [
            LYRPredicate(property: "parts.MIMEType", predicateOperator: .IsEqualTo, value: kMIMETypeVideo),
            LYRPredicate(property: "parts.transferStatus", predicateOperator: .IsIn, value: statuses),
            // TODO: Technically we should not restrict by this, but in practice a non-trivial # of thumbnails get stuck in downloading state
            // Maybe we should figure out some other work around?
            LYRPredicate(property: "isUnread", predicateOperator: .IsEqualTo, value: true),
//            LYRPredicate(property: "sender.userID", predicateOperator: .IsNotEqualTo, value: userId),
        ]
        if let conversation = conversation {
            predicates.append(LYRPredicate(property: "conversation", predicateOperator: .IsEqualTo, value: conversation))
        }
        query.predicate = LYRCompoundPredicate(type: .And, subpredicates: predicates)
        return query
    }
}