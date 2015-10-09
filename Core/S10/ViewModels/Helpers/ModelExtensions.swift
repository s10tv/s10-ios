//
//  UserExtensions.swift
//  S10
//
//  Created by Tony Xiao on 7/25/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ObjectMapper

extension User {
    func dyn(keyPath: UserKeys) -> DynamicProperty {
        return dyn(keyPath.rawValue)
    }
    
    func serverStatus() -> String {
        if let connection = connection,
            let status = connection.lastMessageStatus {
            let receivedLast = (self == connection.lastSender)
            let formattedDate = Formatters.formatRelativeDate(connection.updatedAt)!
            let action: String = {
                switch status {
                case .Sent: return receivedLast ? "Received" : "Sent"
                case .Opened: return receivedLast ? "Received" : "Opened"
                case .Expired: return receivedLast ? "Received" : "Opened"
                }
            }()
            return "\(action) \(formattedDate)"
        }
        return ""
    }
        
    func pDisplayName() -> ProducerProperty<String> {
        return ProducerProperty(combineLatest(
            dyn(.firstName).producer,
            dyn(.lastName).producer,
            dyn(.gradYear).producer
        ).map {
            Formatters.formatFullname($0 as? String, lastName: $1 as? String, gradYear: $2 as? String)
        })
    }
    
    func pAvatar() -> PropertyOf<Image?> {
        return dyn(.avatar_).map(Mapper<Image>().map)
    }
    
    func pCover() -> PropertyOf<Image?> {
        return dyn(.cover_).map(Mapper<Image>().map)
    }
    
    func pFirstName() -> PropertyOf<String> {
        return dyn(.firstName).optional(String).map { $0 ?? "" }
    }
    
    func pLastName() -> PropertyOf<String> {
        return dyn(.lastName).optional(String).map { $0 ?? "" }
    }
    
    func pGradYear() -> PropertyOf<String> {
        return dyn(.gradYear).optional(String).map { $0 ?? "" }
    }
    
    func pMajor() -> PropertyOf<String> {
        return dyn(.major).optional(String).map { $0 ?? "" }
    }
    
    func pHometown() -> PropertyOf<String> {
        return dyn(.hometown).optional(String).map { $0 ?? "" }
    }
    
    func pAbout() -> PropertyOf<String> {
        return dyn(.about).optional(String).map { $0 ?? "" }
    }
    
    func pConnectedProfiles() -> PropertyOf<[ConnectedProfile]> {
        return dyn(.connectedProfiles_).map { Mapper<ConnectedProfile>().mapArray($0) ?? [] }
    }
}

extension Connection {
    func dyn(keyPath: ConnectionKeys) -> DynamicProperty {
        return dyn(keyPath.rawValue)
    }
    
    func pTitle() -> PropertyOf<String> {
        return dyn(.title).optional(String).map { $0 ?? "" }
    }
    
    func pThumbnail() -> PropertyOf<Image?> {
        return dyn(.thumbnail_).map(Mapper<Image>().map)
    }
    
    func pCover() -> PropertyOf<Image?> {
        return dyn(.cover_).map(Mapper<Image>().map)
    }
}

extension Message {
    func dyn(keyPath: MessageKeys) -> DynamicProperty {
        return dyn(keyPath.rawValue)
    }
    
    func pStatus() -> PropertyOf<Status?> {
        return dyn(.status_).optional(String).map { $0.flatMap { Status(rawValue: $0) } }
    }
}

extension Conversation {
    func allPlayableMessages(meteor: MeteorService) -> [MessageViewModel] {
        // TODO: Move this off the main thread
        assert(NSThread.isMainThread(), "Must be performed on main for now")
        
        let messages = messagesFinder
            // MASSIVE HACK ALERT: Ascending should be true but empirically
            // ascending = false seems to actually give us the correct result. FML.
            .sorted(by: MessageKeys.createdAt.rawValue, ascending: false)
            .fetch().map { $0 as! Message }
        
        var playableMessages: [MessageViewModel] = []
        for message in messages {
            if let localURL = VideoCache.sharedInstance.getVideo(message.documentID!) {
                playableMessages.append(MessageViewModel(meteor: meteor, message: message, localVideoURL: localURL))
            }
        }
        return playableMessages
    }
    
    func unreadPlayableMessages(meteor: MeteorService) -> [MessageViewModel] {
        return allPlayableMessages(meteor).filter { $0.unread.value }
    }
    
    // NOTE: ManagedObjectContext changes are ignored
    // So if video is removed nothing will happen
    
    func allPlayableMessagesProperty(meteor: MeteorService) -> ArrayProperty<MessageViewModel> {
        let updates = unsafeNewRealm().notifier().map { _ in
            return self.allPlayableMessages(meteor)
        }
        return ArrayProperty(allPlayableMessages(meteor), updates: updates)
    }
    
    func unreadPlayableMessagesProperty(meteor: MeteorService) -> ArrayProperty<MessageViewModel> {
        let updates = unsafeNewRealm().notifier().map { _ in
            return self.unreadPlayableMessages(meteor)
        }
        return ArrayProperty(unreadPlayableMessages(meteor), updates: updates)
    }
}
