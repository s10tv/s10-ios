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
    let currentUser: CurrentUser
    
    public init(meteor: MeteorService, currentUser: CurrentUser) {
        self.meteor = meteor
        self.currentUser = currentUser
    }
    
    public func recipientForConversation(conversation: LYRConversation) -> UserViewModel? {
        let others = conversation.participants.filter { $0 != currentUser.userId.value }
        if let userId = others.first as? String,
            let u = meteor.mainContext.existingObjectInCollection("users", documentID: userId) as? User {
            return UserViewModel(user: u)
        }
        return nil
    }
    
    public func conversationVM(conversation: LYRConversation) -> LayerConversationViewModel {
        return LayerConversationViewModel(meteor: meteor, currentUser: currentUser, conversation: conversation)
    }
    
}