//
//  ConversationViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/25/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

func messageLoader(conversation: Conversation) -> () -> [MessageViewModel] {
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
                playableMessages.append(MessageViewModel(message: message, localVideoURL: localURL))
            }
        }
        return playableMessages
    }
}

// Class or struct?
public class ConversationViewModel {
    public enum Page : Int {
        case Player = 0
        case Producer = 1
    }
    public enum State {
        case PlaybackStopped
        case PlaybackPlaying
        case RecordIdle
        case RecordCapturing
    }

    let meteor: MeteorService
    let taskService: TaskService
    let _messages: MutableProperty<[MessageViewModel]>
    let _hasUnreadMessage = MutableProperty(false)
    let conversation: Conversation
    
    public let playing: MutableProperty<Bool>
    public let recording: MutableProperty<Bool>
    public let page: MutableProperty<Page>
    
    public let state: PropertyOf<State>
    public let avatar: PropertyOf<Image?>
    public let cover: PropertyOf<Image?>
    public let displayName: PropertyOf<String>
    public let displayStatus: ProducerProperty<String>
    public let busy: ProducerProperty<Bool>
    public let messages: PropertyOf<[MessageViewModel]>
    public let hideNewMessagesHint: PropertyOf<Bool>
    public let showTutorial: Bool
    
    public let currentMessage: MutableProperty<MessageViewModel?>
  
    init(meteor: MeteorService, taskService: TaskService, conversation: Conversation) {
        self.meteor = meteor
        self.taskService = taskService
        self.conversation = conversation
        let loadMessages = messageLoader(conversation)
        let showTutorial = UD.showPlayerTutorial.value ?? true
        
        self.showTutorial = showTutorial
        
        _messages = MutableProperty(loadMessages())
        messages = PropertyOf(_messages)
        playing = MutableProperty(false)
        recording = MutableProperty(false)
        page = MutableProperty((_messages.value.count > 0 || showTutorial) ? .Player : .Producer)
        state = PropertyOf(.PlaybackStopped, combineLatest(
            page.producer,
            playing.producer,
            recording.producer
        ).map {
            switch $0 {
            case .Player: return $1 ? .PlaybackPlaying : .PlaybackStopped
            case .Producer: return $2 ? .RecordCapturing : .RecordIdle
            }
        })
        
        currentMessage = MutableProperty(nil)
        
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
        
        // TODO: Properly implement me taking into account both connection case as well as user case
        hideNewMessagesHint = PropertyOf(_hasUnreadMessage)
        
        // NOTE: ManagedObjectContext changes are ignored
        // So if video is removed nothing will happen
        _messages <~ unsafeNewRealm().notifier().map { _ in loadMessages() }.skipRepeats { $0 == $1 }
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