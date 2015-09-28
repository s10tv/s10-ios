//
//  ConversationViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/25/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import RealmSwift

func messageLoader(sender: User?) -> () -> [MessageViewModel] {
    return {
        // TODO: Move this off the main thread
        assert(NSThread.isMainThread(), "Must be performed on main for now")
        let query = sender.map {
            Message.by(MessageKeys.sender.rawValue, value: $0)
            } ?? Message.all()
        
        let messages = query
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
    let recipient: User?
    let currentUser: PropertyOf<User?>
    let currentMessageDate: PropertyOf<String?>
    let currentConversationStatus: PropertyOf<String?>
    let openedMessages: MutableProperty<Set<Message>>
    
    public let playing: MutableProperty<Bool>
    public let recording: MutableProperty<Bool>
    public let page: MutableProperty<Page>
    
    public let state: PropertyOf<State>
    public let avatar: PropertyOf<Image?>
    public let cover: PropertyOf<Image?>
    public let firstName: PropertyOf<String>
    public let displayName: PropertyOf<String>
    public let displayStatus: PropertyOf<String>
    public let busy: PropertyOf<Bool>
    public let messages: PropertyOf<[MessageViewModel]>
    public let hideReplayButton: PropertyOf<Bool>
    public let hideNewMessagesHint: PropertyOf<Bool>
    public let showTutorial: Bool
    public let exitAtEnd: Bool
    
    public let currentMessage: MutableProperty<MessageViewModel?>
  
    init(meteor: MeteorService, taskService: TaskService, recipient: User?) {
        self.meteor = meteor
        self.taskService = taskService
        self.recipient = recipient
        let loadMessages = messageLoader(recipient)
        let showTutorial = UD.showPlayerTutorial.value ?? true
        
        self.showTutorial = showTutorial
        exitAtEnd = recipient == nil
        
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
        openedMessages = MutableProperty(Set())
        
        currentMessage = MutableProperty(nil)
        currentUser = currentMessage
           .map { $0?.message.sender ?? recipient }
        avatar = currentUser
           .flatMap { $0.pAvatar() }
        cover = currentUser
           .flatMap { $0.pCover() }
        firstName = currentUser
           .flatMap(nilValue: "") { $0.pFirstName() }
        displayName = currentUser
           .flatMap(nilValue: "") { $0.pDisplayName() }
        busy = currentUser
           .flatMap(nilValue: false) { $0.pConversationBusy() }
        
        hideReplayButton = _messages.map { $0.count == 0 }
        hideNewMessagesHint = PropertyOf(true, combineLatest(
            messages.producer,
            openedMessages.producer
        ).map {
            $0.count == $1.count
        })
        
        currentMessageDate = currentMessage
           .flatMap { $0.formattedDate.map { Optional($0) } }
        currentConversationStatus = currentUser
           .flatMap { $0.pConversationStatus().map { Optional($0) } }
        displayStatus = PropertyOf("", combineLatest(
            state.producer,
            currentMessageDate.producer,
            currentConversationStatus.producer
        ).map {
            switch $0 {
            case .PlaybackStopped, .PlaybackPlaying:
                return $1 ?? $2 ?? ""
            case .RecordIdle, .RecordCapturing:
                return $2 ?? ""
            }
        })
        
        // NOTE: ManagedObjectContext changes are ignored
        // So if video is removed nothing will happen
        _messages <~ unsafeNewRealm().notifier().map { _ in loadMessages() }.skipRepeats { $0 == $1 }
    }
    
    public func finishTutorial() {
        UD.showPlayerTutorial.value = false
    }
    
    public func openMessage(message: MessageViewModel) {
        var msgs = openedMessages.value
        msgs.insert(message.message)
        openedMessages.value = msgs
    }
    
    public func expireOpenedMessages() {
        for message in openedMessages.value {
            VideoCache.sharedInstance.removeVideo(message.documentID!)
        }
        meteor.expireMessages(Array(openedMessages.value))
    }
    
    public func sendVideo(video: Video) {
        if let user = currentUser.value {
            taskService.uploadVideo(user, localVideo: video)
        }
    }
    
    public func reportUser(reason: String) {
        if let u = currentUser.value { meteor.reportUser(u, reason: reason) }
    }
    
    public func blockUser() {
        if let u = currentUser.value { meteor.blockUser(u) }
    }
    
    public func profileVM() -> ProfileViewModel {
        return ProfileViewModel(meteor: meteor, taskService: taskService, user: currentUser.value!)
    }
}