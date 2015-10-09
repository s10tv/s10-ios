//
//  ChatHistoryViewModel.swift
//  S10
//
//  Created by Tony Xiao on 10/8/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

// TODO: Struct vs. class?
// For some reason struct causes crash, also doesn't work quite well with the idea of
// delegate. Need to figure out a better pattern of whether struct or class is the right
// approach and when
// http://www.objc.io/issues/16-swift/swift-classes-vs-structs/#the-advantages-of-value-types
public class ChatHistoryViewModel {
    private let currentVideo = MutableProperty<MessageViewModel?>(nil)
    private let currentVideoPosition = MutableProperty<NSTimeInterval>(0)
    private let _isPlaying = MutableProperty(false)
    private let meteor: MeteorService

    public let messages: ArrayProperty<MessageViewModel>
    public let isPlaying: PropertyOf<Bool>
    public let currentVideoURL: PropertyOf<NSURL?>
    public let currentVideoProgress: PropertyOf<Float>
    public let durationLeft: PropertyOf<String>
    public let hidePlaybackViews: PropertyOf<Bool>
    
    init(meteor: MeteorService, conversation: Conversation) {
        self.meteor = meteor
        messages = conversation.allPlayableMessagesProperty(meteor)
        currentVideoURL = currentVideo.map { $0?.url }
        isPlaying = PropertyOf(_isPlaying)
        currentVideoProgress = PropertyOf(0, combineLatest(
            currentVideo.producer,
            currentVideoPosition.producer
        ).map { video, time in
            video.map { Float(min(time / $0.duration, 1)) } ?? 0
        })
        durationLeft = PropertyOf("", combineLatest(
            currentVideoPosition.producer,
            currentVideo.producer
        ).map { currentTime, video in
            let duration = video?.duration ?? 0
            let secondsLeft = Int(ceil(max(duration - currentTime, 0)))
            return "\(secondsLeft)"
        })
        hidePlaybackViews = currentVideo.map { $0 == nil }
    }
    
    public func prevVideo() -> MessageViewModel? {
        if currentVideo.value == nil {
            return messages.array.last
        }
        return currentMessageIndex().flatMap {
            $0 > 0 ? $0 - 1 : nil
        }.map { messages.array[$0] }
    }
    
    public func nextVideo() -> MessageViewModel? {
        if currentVideo.value == nil {
            return messages.array.first
        }
        return currentMessageIndex().flatMap {
            $0 < messages.array.count - 1 ? $0 + 1 : nil
        }.map { messages.array[$0] }
    }
    
    public func seekPrevVideo() -> Bool {
        return seekVideo(prevVideo())
    }
    
    public func seekVideoAtIndex(index: Int) -> Bool {
        return seekVideo(messages.array[index])
    }
    
    public func seekNextVideo() -> Bool {
        return seekVideo(nextVideo())
    }
    
    // MARK: - Hooks for PlayerViewController to update state
    
    public func updatePlaybackPosition(position: NSTimeInterval) {
        currentVideoPosition.value = position
    }
    
    public func updateIsPlaying(isPlaying: Bool) {
        _isPlaying.value = isPlaying
    }
    
    public func finishPlayback() {
        seekVideo(nil)
    }
    
    // MARK: -
    
    private func seekVideo(video: MessageViewModel?) -> Bool {
        Log.debug("Will seek video with id \(video) url: \(video?.url)")
        if let video = currentVideo.value where video.unread.value == true {
            meteor.openMessage(video.message)
        }
        currentVideoPosition.value = 0
        currentVideo.value = video
        return video != nil
    }
    
    private func currentMessageIndex() -> Int? {
        for (index, v) in messages.array.enumerate() {
            if v == currentVideo.value { return index }
        }
        return nil
    }
}
