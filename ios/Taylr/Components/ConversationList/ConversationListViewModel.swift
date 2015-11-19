//
//  ConversationListViewModel.swift
//  S10
//
//  Created by Tony Xiao on 10/14/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import LayerKit

public class ConversationListViewModel: NSObject {
    
    let layerClient: LYRClient
    let currentUser: UserViewModel
    
    init(layerClient: LYRClient, currentUser: UserViewModel) {
        self.layerClient = layerClient
        self.currentUser = currentUser
    }
    
    func firstOtherParticipant(conversation: LYRConversation) -> UserViewModel? {
        return conversation.otherParticipants(currentUser.userId).first
    }
    
    func displayNameForConversation(conversation: LYRConversation) -> String {
        if let title = conversation.title {
            return conversation.participants.count > 2 ? "\(title) (\(conversation.participants.count))" : title
        } else if let p = firstOtherParticipant(conversation) {
            return p.displayName
        }
        return ""
    }
    
    func avatarForConversation(conversation: LYRConversation) -> Image? {
        if let avatarURL = conversation.avatarURL {
            return Image(avatarURL)
        } else if let p = firstOtherParticipant(conversation) {
            return p.avatarURL.map { Image($0) }
        }
        return nil
    }
    
    func lastMessageTextForConversation(conversation: LYRConversation) -> String {
        if let msg = conversation.lastMessage where msg.videoPart != nil {
            let sentBySelf = msg.sender.userID == currentUser.userId
            if sentBySelf {
                if !msg.isSent {
                    return "> Sending..."
                }
                let status = Formatters.stringForDisplayOfRecipientStatus(msg.recipientStatusByUserID, currentUser: currentUser)
                return "> Video \(status.lowercaseString)"
            } else {
                return "> Received video"
            }
        }
        return conversation.lastMessage?.textPart?.asString() ?? ""
    }
    
//    public func conversationVM(conversation: LYRConversation) -> ConversationViewModel {
//        return ConversationViewModel(ctx, conversation: conversation)
//    }
    
}