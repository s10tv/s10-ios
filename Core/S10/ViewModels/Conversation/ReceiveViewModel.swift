//
//  ReceiveViewModel.swift
//  S10
//
//  Created by Tony Xiao on 10/8/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

public class ReceiveViewModel {
    private let meteor: MeteorService
    
    public let playlist: ArrayProperty<MessageViewModel>
    public let totalDurationLeft: PropertyOf<String>
    public let currentVideo: PropertyOf<MessageViewModel?>
    public let currentVideoProgress: PropertyOf<Float>
    public let currentVideoPosition = MutableProperty<NSTimeInterval>(0)
    public let isPlaying = MutableProperty(false)
    
    init(meteor: MeteorService, conversation: Conversation) {
        self.meteor = meteor
        playlist = conversation.unreadPlayableMessagesProperty(meteor)
        currentVideo = PropertyOf(nil, playlist.producer.map { $0.first }.skipRepeats { $0 == $1 })
        currentVideoProgress = PropertyOf(0, combineLatest(
            currentVideo.producer,
            currentVideoPosition.producer
        ).map { video, time in
            video.map { Float(min(time / $0.duration, 1)) } ?? 0
        })
        totalDurationLeft = PropertyOf("", combineLatest(
            currentVideoPosition.producer,
            playlist.producer
        ).map { position, playlist in
            let total = playlist.map { $0.duration }.reduce(0, combine: +)
            let secondsLeft = Int(ceil(max(total - position, 0)))
            return "\(secondsLeft)"
        })
    }
    
    public func seekNextVideo() -> Bool {
        if let video = playlist.dequeue() {
            meteor.openMessage(video.message)
        }
        return currentVideo.value != nil
    }
}

