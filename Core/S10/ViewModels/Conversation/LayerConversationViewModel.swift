//
//  LayerConversationViewModel.swift
//  S10
//
//  Created by Tony Xiao on 10/15/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import LayerKit

public class LayerConversationViewModel: NSObject {
    
    let meteor: MeteorService
    let currentUser: CurrentUser
    public let avatar: PropertyOf<Image?>
    public let cover: PropertyOf<Image?>
    public let displayName: ProducerProperty<String>
    public let displayStatus = PropertyOf("")
    
    public let conversation: LYRConversation
    
    init(meteor: MeteorService, currentUser: CurrentUser, conversation: LYRConversation) {
        if let u = conversation.recipient(meteor.mainContext, currentUserId: currentUser.userId.value) {
            avatar = u.pAvatar()
            cover = u.pCover()
            displayName = u.pDisplayName()
        } else {
            avatar = PropertyOf(nil)
            cover = PropertyOf(nil)
            displayName = ProducerProperty(SignalProducer(value: ""))
        }
        self.meteor = meteor
        self.currentUser = currentUser
        self.conversation = conversation
    }
    
    public func recipient() -> UserViewModel? {
        if let u = conversation.recipient(meteor.mainContext, currentUserId: currentUser.userId.value) {
            return UserViewModel(user: u)
        }
        return nil
    }
}