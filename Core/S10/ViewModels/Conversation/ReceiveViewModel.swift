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
    private let currentVideoPosition = MutableProperty<NSTimeInterval>(0)
    private let _currentVideo = MutableProperty<MessageViewModel?>(nil)
    private let _isPlaying = MutableProperty(false)
    private let meteor: MeteorService
    
    public let playlist: ArrayProperty<MessageViewModel>
    public let totalDurationLeft: PropertyOf<String>
    public let currentVideo: PropertyOf<MessageViewModel?>
    public let currentVideoProgress: PropertyOf<Float>
    public let isPlaying: PropertyOf<Bool>
    
    init(meteor: MeteorService, conversation: Conversation) {
        self.meteor = meteor
        playlist = conversation.unreadPlayableMessagesProperty(meteor)
        currentVideo = PropertyOf(_currentVideo)
        isPlaying = PropertyOf(_isPlaying)
        currentVideoProgress = PropertyOf(0, combineLatest(
            currentVideo.producer,
            currentVideoPosition.producer
        ).map { video, time in
            video.map { Float(min(time / $0.duration, 1)) } ?? 0
        })
        totalDurationLeft = PropertyOf("", combineLatest(
            currentVideo.producer,
            currentVideoPosition.producer,
            playlist.producer
        ).map { video, position, playlist in
            let total = playlist.map { $0.duration }.reduce(0, combine: +) + (video?.duration ?? 0)
            let secondsLeft = Int(ceil(max(total - position, 0)))
            return "\(secondsLeft)"
        })
    }
    
    public func seekNextVideo() -> Bool {
        if let video = currentVideo.value {
            meteor.openMessage(video.message)
        }
        _currentVideo.value = playlist.dequeue()
        return currentVideo.value != nil
    }
    
    // MARK: - Hooks for PlayerViewController to update state
    
    public func updatePlaybackPosition(position: NSTimeInterval) {
        currentVideoPosition.value = position
    }
    
    public func updateIsPlaying(isPlaying: Bool) {
        _isPlaying.value = isPlaying
    }
}

