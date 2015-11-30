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
import React

public class ConversationListViewModel: NSObject {
    
    let layerClient: LYRClient
    let currentUserId: String
    
    init(layerClient: LYRClient, currentUserId: String) {
        self.layerClient = layerClient
        self.currentUserId = currentUserId
    }
    
    func firstOtherParticipant(conversation: LYRConversation) -> UserViewModel? {
        return conversation.otherParticipants(currentUserId).first
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
            let sentBySelf = msg.sender.userID == currentUserId
            if sentBySelf {
                if !msg.isSent {
                    return "> Sending..."
                }
                let status = Formatters.stringForDisplayOfRecipientStatus(msg.recipientStatusByUserID, currentUserId: currentUserId)
                return "> Video \(status.lowercaseString)"
            } else {
                return "> Received video"
            }
        }
        return conversation.lastMessage?.textPart?.asString() ?? ""
    }
}