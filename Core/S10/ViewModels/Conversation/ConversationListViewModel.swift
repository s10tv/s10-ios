//
//  ConversationListViewModel.swift
//  S10
//
//  Created by Tony Xiao on 10/14/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Meteor
import LayerKit

public class ConversationListViewModel: NSObject {
    
    let ctx: Context
    public let changedConversations: Signal<LYRConversation, NoError>
    
    public init(_ ctx: Context) {
        self.ctx = ctx
        
        let (signal, _) = Signal<LYRConversation, NoError>.pipe()
        changedConversations = signal.observeOn(UIScheduler())
        // TODO: Reload conversation if conversation metadata changes rather than when user changes
//        users.databaseChanges.observeNext { changes in
//            changes.enumerateDocumentChangeDetailsUsingBlock { details, _ in
//                if details.documentKey.collectionName == "users" {
//                    let userId = details.documentKey.documentID as! String
//                    ctx.layer.findConversationsWithUserId(userId).each {
//                        sendNext(sink, $0)
//                    }
//                }
//            }
//        }
    }
    
    public func displayNameForConversation(conversation: LYRConversation) -> String {
        if let title = conversation.title {
            return conversation.participants.count > 2 ? "\(title) (\(conversation.participants.count))" : title
        } else if let p = conversation.otherParticipants(ctx.currentUserId).first {
            return p.displayName
        }
        return ""
    }
    
    public func avatarForConversation(conversation: LYRConversation) -> Image? {
        if let avatarURL = conversation.avatarURL {
            return Image(avatarURL)
        } else if let p = conversation.otherParticipants(ctx.currentUserId).first {
            return p.avatarURL.map { Image($0) }
        }
        return nil
    }
    
    public func lastMessageTextForConversation(conversation: LYRConversation) -> String {
        if let msg = conversation.lastMessage where msg.videoPart != nil {
            let sentBySelf = msg.sender.userID == ctx.currentUserId
            if sentBySelf {
                if !msg.isSent {
                    return "> Sending..."
                }
                let status = Formatters.stringForDisplayOfRecipientStatus(msg.recipientStatusByUserID, ctx: ctx)
                return "> Video \(status.lowercaseString)"
            } else {
                return "> Received video"
            }
        }
        return conversation.lastMessage?.textPart?.asString() ?? ""
    }
    
    public func recipientForConversation(conversation: LYRConversation) -> UserViewModel? {
        if let p = conversation.otherParticipants(ctx.currentUserId).first {
            return UserViewModel(participant: p)
        }
        return nil
    }
    
    public func conversationVM(conversation: LYRConversation) -> ConversationViewModel {
        return ConversationViewModel(ctx, conversation: conversation)
    }
    
}