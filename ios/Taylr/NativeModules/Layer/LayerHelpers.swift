//
//  LayerHelpers.swift
//  S10
//
//  Created by Tony Xiao on 10/15/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import LayerKit
import Atlas

// MARK: - ATLParticipant

extension UserViewModel : ATLParticipant {
    var participantIdentifier: String { return userId }
    var fullName: String { return displayName }
    var avatarImageURL: NSURL? { return avatarURL }
    var avatarImage: UIImage? { return nil }
    var avatarInitials: String? {
        return "\(firstName.characters.first)\(lastName.characters.first)"
    }
}

// MARK: - Conversation Participant

extension UserViewModel {
    var kAvatarURL: String { return "users_\(userId)_avatarUrl" }
    var kCoverURL: String { return "users_\(userId)_coverUrl" }
    var kDisplayName: String { return "users_\(userId)_displayName" }
    var kFirstName: String { return "users_\(userId)_firstName" }
    var kLastName: String { return "users_\(userId)_lastName" }
    
    convenience init(userId: String, inConversation c: LYRConversation) {
        self.init(userId: userId)
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

// MARK: -

extension LYRMessage {
    enum MessageType: String {
        case Text = "Text"
        case Video = "Video"
        case Location = "Location"
        case Other = "Other"
    }
    
    var messageType: MessageType {
        for part in messageParts {
            switch part.MIMEType {
            case kMIMETypeText: return .Text
            case kMIMETypeVideo: return .Video
            case kMIMETypeLocation: return .Location
            default:
                break
            }
        }
        return .Other
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
    
    func otherParticipants(currentUserId: String?) -> [UserViewModel] {
        return otherUserIds(currentUserId).map { UserViewModel(userId: $0, inConversation: self) }
    }

    func participantForId(userId: String) -> UserViewModel? {
        return participants.contains(userId) ? UserViewModel(userId: userId, inConversation: self) : nil
    }
}

