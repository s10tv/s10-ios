//
//  LayerHelpers.swift
//  S10
//
//  Created by Tony Xiao on 10/15/15.
//  Copyright © 2015 S10. All rights reserved.
//

// Domain-specific helpers on top of Layer

import Foundation
import LayerKit

public class Participant : NSObject {
    var kAvatarURL: String { return "users_\(userId)_avatarUrl" }
    var kCoverURL: String { return "users_\(userId)_coverUrl" }
    var kDisplayName: String { return "users_\(userId)_displayName" }
    var kFirstName: String { return "users_\(userId)_firstName" }
    var kLastName: String { return "users_\(userId)_lastName" }
    
    public let userId: String
    public var avatarURL: NSURL? = nil
    public var coverURL: NSURL? = nil
    public var firstName: String = ""
    public var lastName: String = ""
    public var displayName: String = ""
    
    init(user: User) {
        userId = user.documentID!
        avatarURL = user.avatar?.url
        coverURL = user.cover?.url
        firstName = user.firstName ?? ""
        lastName = user.lastName ?? ""
        displayName = user.displayName()
        super.init()
    }
    
    init(userId: String, inConversation c: LYRConversation) {
        self.userId = userId
        super.init()
        avatarURL = (c.metadata[kAvatarURL] as? String).flatMap { NSURL(string: $0) }
        coverURL = (c.metadata[kCoverURL] as? String).flatMap { NSURL(string: $0) }
        firstName = c.metadata[kFirstName] as? String ?? ""
        lastName = c.metadata[kLastName] as? String ?? ""
        displayName = c.metadata[kDisplayName] as? String ?? ""
    }
    
    func asDictionary() -> [String: String] {
        return [
            kAvatarURL: avatarURL?.absoluteString ?? "",
            kCoverURL: coverURL?.absoluteString ?? "",
            kFirstName: firstName,
            kLastName: lastName,
            kDisplayName: displayName,
        ]
    }
}

extension LYRConversation {
    var kTitle: String { return "title" }
    var kAvatarUrl: String { return "avatarUrl" }
    var kCoverUrl: String { return "coverUrl" }
    
    var title: String? {
        get { return metadata[kTitle] as? String }
        set { setValue(newValue, forMetadataAtKeyPath: kTitle) }
    }
    
    var avatarURL: NSURL? {
        get { return (metadata[kAvatarUrl] as? String).flatMap { NSURL(string: $0) } }
        set { setValue(newValue, forMetadataAtKeyPath: kAvatarUrl) }
    }
    
    var coverURL: NSURL? {
        get { return (metadata[kCoverUrl] as? String).flatMap { NSURL(string: $0) } }
        set { setValue(newValue, forMetadataAtKeyPath: kCoverUrl) }
    }
    
    func otherUserIds(currentUserId: String?) -> Set<String> {
        return Set(participants.filter { $0 != currentUserId }.map { $0 as! String })
    }
    
    func otherParticipants(currentUserId: String?) -> [Participant] {
        return otherUserIds(currentUserId).map { Participant(userId: $0, inConversation: self) }
    }

    func participantForId(userId: String) -> Participant? {
        return participants.contains(userId) ? Participant(userId: userId, inConversation: self) : nil
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
