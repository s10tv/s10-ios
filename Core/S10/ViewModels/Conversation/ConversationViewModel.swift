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
    
    let meteor: MeteorService
    let currentUser: CurrentUser
    let taskService: TaskService
    public let avatar: PropertyOf<Image?>
    public let cover: PropertyOf<Image?>
    public let displayName: ProducerProperty<String>
    public let displayStatus = PropertyOf("")
    
    public let conversation: LYRConversation
    
    init(meteor: MeteorService, taskService: TaskService, conversation: LYRConversation) {
        self.meteor = meteor
        self.currentUser = meteor.currentUser
        self.taskService = taskService
        self.conversation = conversation
        if let u = conversation.recipient(meteor.mainContext, currentUserId: currentUser.userId.value) {
            avatar = u.pAvatar()
            cover = u.pCover()
            displayName = u.pDisplayName()
        } else {
            avatar = PropertyOf(nil)
            cover = PropertyOf(nil)
            displayName = ProducerProperty(SignalProducer(value: ""))
        }
    }
    
    public func recipient() -> UserViewModel? {
        if let u = conversation.recipient(meteor.mainContext, currentUserId: currentUser.userId.value) {
            return UserViewModel(user: u)
        }
        return nil
    }
    
    public func reportUser(reason: String) {
        if let u = conversation.recipient(meteor.mainContext, currentUserId: currentUser.userId.value) {
            meteor.reportUser(u, reason: reason)
        }
    }
    
    public func blockUser() {
        if let u = conversation.recipient(meteor.mainContext, currentUserId: currentUser.userId.value) {
            meteor.blockUser(u)
        }
    }
    
    public func profileVM() -> ProfileViewModel? {
        if let u = conversation.recipient(meteor.mainContext, currentUserId: currentUser.userId.value) {
            return ProfileViewModel(meteor: meteor, taskService: taskService, user: u)
        }
        return nil
    }
}