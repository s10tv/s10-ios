//
//  ConversationViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/25/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Bond

public struct PlaybackViewModel {
    let _currentMessage = MutableProperty<MessageViewModel?>(nil)
    let _currentTrackRatio = MutableProperty<CGFloat>(0)
    let _totalTimeRemaining = MutableProperty<String>("")
    
    public var currentMessage: PropertyOf<MessageViewModel?> {
        return PropertyOf(_currentMessage)
    }
    public var currentTrackRatio: PropertyOf<CGFloat> {
        return PropertyOf(_currentTrackRatio)
    }
    public var totalTimeRemaining: PropertyOf<String> {
        return PropertyOf(_totalTimeRemaining)
    }
}

public struct RecordViewModel {
    let _hasNewMessage = MutableProperty<Bool>(false)

    public var hasNewMessage: PropertyOf<Bool> {
        return PropertyOf(_hasNewMessage)
    }
}

public struct ConversationViewModel {

    let meteor: MeteorService
    let messages = DynamicArray<MessageViewModel>([])
    let recipient: User?
    
    public let avatar: PropertyOf<Image?>
    public let displayName: PropertyOf<String>
    public let displayStatus: PropertyOf<String>
    public let busy: PropertyOf<Bool>

    public let playback: PlaybackViewModel
    public let record: RecordViewModel

    init(meteor: MeteorService, recipient: User?) {
        self.meteor = meteor
        self.recipient = recipient
        playback = PlaybackViewModel()
        record = RecordViewModel()
        let currentUser = playback._currentMessage
            |> map { $0?.message.sender ?? recipient }
        avatar = currentUser
            |> flatMap { $0.pAvatar() }
        displayName = currentUser
            |> flatMap(nilValue: "") { $0.pDisplayName() }
        busy = currentUser
            |> flatMap(nilValue: false) { $0.pConversationBusy() }
        displayStatus = playback._currentMessage
            |> flatMap { $0?.formattedDate ?? recipient?.pConversationStatus() ?? PropertyOf("") }
    }
    
    // BUGBUG: Never called thus no message will show up
    public func reloadMessages() {
        let messages = Message
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
        if self.messages.value != playableMessages {
            self.messages.setArray(playableMessages)
        }
    }
    
    public func profileVM() -> ProfileViewModel {
        let user = playback.currentMessage.value?.message.sender ?? recipient!
        return ProfileViewModel(meteor: meteor, user: user)
    }
}