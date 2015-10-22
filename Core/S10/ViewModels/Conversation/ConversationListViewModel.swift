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
    var subscriptions: [MeteorSubscription] = []

    let changedConversationSink: Event<LYRConversation, NoError> -> ()
    public let changedConversations: Signal<LYRConversation, NoError>
    
    public init(_ ctx: Context) {
        self.ctx = ctx
        let (signal, sink) = Signal<LYRConversation, NoError>.pipe()
        changedConversations = signal.observeOn(UIScheduler())
        changedConversationSink = sink
    }
    
    func firstOtherParticipant(conversation: LYRConversation) -> Participant? {
        if let p = conversation.otherParticipants(ctx.currentUserId).first {
            if let u = ctx.meteor.mainContext.existingObjectInCollection("users", documentID: p.userId) as? User {
                // Prefer meteor.user if such user is available
                return Participant(user: u)
            }
            return p
        }
        return nil
    }
    
    public func displayNameForConversation(conversation: LYRConversation) -> String {
        // MASSIVE HACK: Fix issue where new layer conversation does not sync metadata down to client
        // and therefore contact appears as unknown. Try to subscribe to the user in question and use meteor
        // user to compensate.
        if conversation.metadata?.count == 0 {
            for userId in conversation.participants.map({ $0 as! String }) {
                if userId == ctx.currentUserId {
                    continue
                }
                let sub = ctx.meteor.subscribe("user", userId)
                if subscriptions.contains({ $0.subscription.identifier == sub.subscription.identifier }) {
                    continue
                }
                sub.ready.onSuccess { [weak self] in
                    if let sink = self?.changedConversationSink {
                        sendNext(sink, conversation)
                    }
                }
                subscriptions.append(sub)
            }
        }
        if let title = conversation.title {
            return conversation.participants.count > 2 ? "\(title) (\(conversation.participants.count))" : title
        } else if let p = firstOtherParticipant(conversation) {
            return p.displayName
        }
        return ""
    }
    
    public func avatarForConversation(conversation: LYRConversation) -> Image? {
        if let avatarURL = conversation.avatarURL {
            return Image(avatarURL)
        } else if let p = firstOtherParticipant(conversation) {
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
        if let p = firstOtherParticipant(conversation) {
            return UserViewModel(participant: p)
        }
        return nil
    }
    
    public func conversationVM(conversation: LYRConversation) -> ConversationViewModel {
        return ConversationViewModel(ctx, conversation: conversation)
    }
    
}