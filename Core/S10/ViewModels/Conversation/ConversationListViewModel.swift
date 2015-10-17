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
    let chatsSub: MeteorSubscription
    let users: MeteorCollection
    public let changedConversations: Signal<LYRConversation, NoError>
    
    public init(_ ctx: Context) {
        self.ctx = ctx
        chatsSub = ctx.meteor.subscribe("chats")
        users = ctx.meteor.collection("users")
        
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
    
    public func recipientForConversation(conversation: LYRConversation) -> UserViewModel? {
        if let u = conversation.recipient(ctx.meteor.mainContext, currentUserId: ctx.currentUserId) {
            return UserViewModel(user: u)
        }
        if let userId = conversation.recipientId(ctx.currentUserId) {
            return UserViewModel(conversation: conversation, userId: userId)
        }
        return nil
    }
    
    public func conversationVM(conversation: LYRConversation) -> ConversationViewModel {
        return ConversationViewModel(ctx, conversation: conversation)
    }
    
}