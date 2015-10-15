//
//  ConversationViewModel.swift
//  S10
//
//  Created by Tony Xiao on 10/15/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import LayerKit

public class ConversationViewModel: NSObject {
    
    let ctx: Context
    public let avatar: PropertyOf<Image?>
    public let cover: PropertyOf<Image?>
    public let displayName: ProducerProperty<String>
    public let displayStatus = PropertyOf("")
    
    public let conversation: LYRConversation
    
    init(_ ctx: Context, conversation: LYRConversation) {
        self.ctx = ctx
        self.conversation = conversation
        if let u = conversation.recipient(ctx.meteor.mainContext, currentUserId: ctx.currentUserId) {
            avatar = u.pAvatar()
            cover = u.pCover()
            displayName = u.pDisplayName()
        } else {
            avatar = PropertyOf(nil)
            cover = PropertyOf(nil)
            displayName = ProducerProperty(SignalProducer(value: ""))
        }
    }
    
    func user() -> User? {
        return conversation.recipient(ctx.meteor.mainContext, currentUserId: ctx.currentUserId)
    }
    
    public func recipient() -> UserViewModel? {
        if let u = user() {
            return UserViewModel(user: u)
        }
        return nil
    }
    
    public func reportUser(reason: String) {
        if let u = user() {
            ctx.meteor.reportUser(u, reason: reason)
        }
    }
    
    public func blockUser() {
        if let u = user() {
            ctx.meteor.blockUser(u)
        }
    }
    
    public func profileVM() -> ProfileViewModel? {
        if let u = user() {
            return ProfileViewModel(ctx, user: u)
        }
        return nil
    }
}