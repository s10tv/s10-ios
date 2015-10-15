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
    
    let meteor: MeteorService
    let taskService: TaskService
    let currentUser: CurrentUser
    
    public init(meteor: MeteorService, taskService: TaskService) {
        self.meteor = meteor
        self.currentUser = meteor.currentUser
        self.taskService = taskService
    }
    
    public func recipientForConversation(conversation: LYRConversation) -> UserViewModel? {
        if let u = conversation.recipient(meteor.mainContext, currentUserId: currentUser.userId.value) {
            return UserViewModel(user: u)
        }
        return nil
    }
    
    public func conversationVM(conversation: LYRConversation) -> ConversationViewModel {
        return ConversationViewModel(meteor: meteor, taskService: taskService, conversation: conversation)
    }
    
}