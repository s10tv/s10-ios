//
//  LayerConversationViewModel.swift
//  S10
//
//  Created by Tony Xiao on 10/15/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import LayerKit

public class LayerConversationViewModel: NSObject {
    
    let meteor: MeteorService
    let currentUser: CurrentUser
    
    public let conversation: LYRConversation
    
    init(meteor: MeteorService, currentUser: CurrentUser, conversation: LYRConversation) {
        self.meteor = meteor
        self.currentUser = currentUser
        self.conversation = conversation
    }
    
    public func recipient() -> UserViewModel? {
        let others = conversation.participants.filter { $0 != currentUser.userId.value }
        if let userId = others.first as? String,
            let u = meteor.mainContext.existingObjectInCollection("users", documentID: userId) as? User {
                return UserViewModel(user: u)
        }
        return nil
    }
}