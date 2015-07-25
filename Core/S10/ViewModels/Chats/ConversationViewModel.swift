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

    let messages = DynamicArray<MessageViewModel>([])
    let recipient: User?
    
    public let avatar: PropertyOf<Image?>
    public let displayName: PropertyOf<String>
    public let displayStatus: PropertyOf<String>
    public let busy: PropertyOf<Bool>

    public let playback: PlaybackViewModel
    public let record: RecordViewModel

    init(recipient: User?) {
        let playback = PlaybackViewModel()
        let record = RecordViewModel()
        self.recipient = recipient
        self.playback = playback
        self.record = record
        avatar = playback._currentMessage
            |> flatMap { $0?.message.sender.pAvatar() ?? PropertyOf(nil) }
        displayName = playback._currentMessage
            |> flatMap { $0?.message.sender.pDisplayName() ?? PropertyOf("") }
        displayStatus = playback._currentMessage
            |> flatMap { $0?.formattedDate ?? recipient?.pConversationStatus() ?? PropertyOf("") }
        busy = playback._currentMessage
            |> flatMap { $0?.message.sender.pConversationBusy() ?? PropertyOf(false) }
    }
    
    func reloadMessages() {
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
}