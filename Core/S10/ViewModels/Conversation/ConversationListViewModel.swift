//
//  ConversationListViewModel.swift
//  S10
//
//  Created by Tony Xiao on 10/14/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import LayerKit

public class ConversationListViewModel: NSObject {
    
    let ctx: Context
    
    public init(_ ctx: Context) {
        self.ctx = ctx
    }
    
    public func recipientForConversation(conversation: LYRConversation) -> UserViewModel? {
        if let u = conversation.recipient(ctx.meteor.mainContext, currentUserId: ctx.currentUserId) {
            return UserViewModel(user: u)
        }
        return nil
    }
    
    public func conversationVM(conversation: LYRConversation) -> ConversationViewModel {
        return ConversationViewModel(ctx, conversation: conversation)
    }
    
}