//
//  ConversationViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/25/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

func messageLoader(meteor: MeteorService, conversation: Conversation) -> () -> [MessageViewModel] {
    return {
        // TODO: Move this off the main thread
        assert(NSThread.isMainThread(), "Must be performed on main for now")
        
        let messages = conversation.messagesFinder
            // MASSIVE HACK ALERT: Ascending should be true but empirically
            // ascending = false seems to actually give us the correct result. FML.
            .sorted(by: MessageKeys.createdAt.rawValue, ascending: false)
            .fetch().map { $0 as! Message }
        
        var playableMessages: [MessageViewModel] = []
        for message in messages {
            if let localURL = VideoCache.sharedInstance.getVideo(message.documentID!) {
                playableMessages.append(MessageViewModel(meteor: meteor, message: message, localVideoURL: localURL))
            }
        }
        return playableMessages
    }
}

// Class or struct?
public class ConversationViewModel {
    let meteor: MeteorService
    let taskService: TaskService
    let conversation: Conversation
    let subscription: MeteorSubscription?
    
    public let playing: MutableProperty<Bool>
    public let recording: MutableProperty<Bool>
    
    public let avatar: PropertyOf<Image?>
    public let cover: PropertyOf<Image?>
    public let displayName: PropertyOf<String>
    public let displayStatus: ProducerProperty<String>
    public let busy: ProducerProperty<Bool>
    public let hasUnreadMessage: PropertyOf<Bool>
    public let hideNewMessagesHint: PropertyOf<Bool>
    public let showTutorial: Bool
    
    public let receiveVM: ReceiveViewModel
    public let chatHistoryVM: ChatHistoryViewModel
  
    init(meteor: MeteorService, taskService: TaskService, conversation: Conversation) {
        self.meteor = meteor
        self.taskService = taskService
        self.conversation = conversation
        subscription = conversation.connection?.documentID.map {
            meteor.subscribe("messages-by-connection", $0)
        }
        showTutorial = (UD.showPlayerTutorial.value ?? true)
        
        receiveVM = ReceiveViewModel(meteor: meteor, conversation: conversation)
        chatHistoryVM = ChatHistoryViewModel(meteor: meteor, conversation: conversation)
        
        playing = MutableProperty(false)
        recording = MutableProperty(false)
        displayStatus = conversation.pStatus()
        busy = conversation.pBusy()
        
        switch conversation {
        case .Connection(let connection):
            avatar = connection.pThumbnail()
            displayName = connection.pTitle()
            cover = connection.pCover()
        case .User(let user):
            avatar = user.pAvatar()
            displayName = PropertyOf(user.pDisplayName())
            cover = user.pCover()
        }
        hasUnreadMessage = PropertyOf(false, receiveVM.playlist.producer.map { $0.count > 0 })
        hideNewMessagesHint = hasUnreadMessage.map { !$0 }
    }
    
    public func finishTutorial() {
        UD.showPlayerTutorial.value = false
    }
    
    public func openMessage(message: MessageViewModel) {
        meteor.openMessage(message.message)
    }
    
    public func sendVideo(video: Video) {
        taskService.uploadVideo(conversation.id, localVideo: video)
    }
    
    public func reportUser(reason: String) {
        if let u = conversation.user { meteor.reportUser(u, reason: reason) }
    }
    
    public func blockUser() {
        if let u = conversation.user { meteor.blockUser(u) }
    }
    
    public func profileVM() -> ProfileViewModel? {
        if let u = conversation.user {
            return ProfileViewModel(meteor: meteor, taskService: taskService, user: u)
        }
        return nil
    }
}