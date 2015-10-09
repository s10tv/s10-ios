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
    private let totalDuration: PropertyOf<NSTimeInterval>
    private let currentVideo = MutableProperty<MessageViewModel?>(nil)
    private let currentVideoPosition = MutableProperty<NSTimeInterval>(0)
    private let _isPlaying = MutableProperty(false)
    
    public let playlist: ArrayProperty<MessageViewModel>
    public let totalDurationLeft: PropertyOf<String>
    public let currentVideoURL: PropertyOf<NSURL?>
    public let currentVideoProgress: PropertyOf<Float>
    public let isPlaying: PropertyOf<Bool>
    
    init(meteor: MeteorService, conversation: Conversation) {
        playlist = conversation.unreadPlayableMessagesProperty(meteor)
        currentVideoURL = currentVideo.map { $0?.url }
        isPlaying = PropertyOf(_isPlaying)
        totalDuration = PropertyOf(0, playlist.producer.map { array in
            array.map { $0.duration }.reduce(0, combine: +)
        })
        currentVideoProgress = PropertyOf(0, combineLatest(
            currentVideo.producer,
            currentVideoPosition.producer
        ).map { video, time in
            video.map { Float(min(time / $0.duration, 1)) } ?? 0
        })
        totalDurationLeft = PropertyOf("", combineLatest(
            currentVideoPosition.producer,
            totalDuration.producer
        ).map { currentTime, unfinishedVideoDuration in
            let secondsLeft = Int(ceil(max(unfinishedVideoDuration - currentTime, 0)))
            return "\(secondsLeft)"
        })
    }
    
    public func seekNextVideo() -> Bool {
        currentVideo.value = playlist.dequeue()
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
