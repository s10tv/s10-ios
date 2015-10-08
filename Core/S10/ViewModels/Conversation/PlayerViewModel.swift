//
//  PlayerViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/20/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

public protocol PlayerDelegate : class {
    func playerDidFinishPlaylist(player: PlayerViewModel)
    func player(player: PlayerViewModel, willPlayVideo video: MessageViewModel)
    func player(player: PlayerViewModel, didPlayVideo video: MessageViewModel)
}

private func findVideo(video: MessageViewModel?, inPlaylist playlist: [MessageViewModel]) -> Int? {
    for (index, v) in playlist.enumerate() {
        if v.uniqueId == video?.uniqueId {
            return index
        }
    }
    return nil
}

// TODO: Struct vs. class?
// For some reason struct causes crash, also doesn't work quite well with the idea of
// delegate. Need to figure out a better pattern of whether struct or class is the right
// approach and when
// http://www.objc.io/issues/16-swift/swift-classes-vs-structs/#the-advantages-of-value-types
public class PlayerViewModel {
    private let currentVideo = MutableProperty<MessageViewModel?>(nil)
    private let currentTime = MutableProperty<NSTimeInterval>(0)
    private let _isPlaying = MutableProperty(false)
    private let unfinishedVideoDuration: PropertyOf<NSTimeInterval>
    public weak var delegate: PlayerDelegate?
    
    public let videos: ArrayProperty<MessageViewModel>
    
    public let playlist = MutableProperty<[MessageViewModel]>([])
    public let videoURL: PropertyOf<NSURL?>
    public let isPlaying: PropertyOf<Bool>
    public let hideOverlay: PropertyOf<Bool>
    public let currentVideoProgress: PropertyOf<Float>
    public let totalDurationLeft: PropertyOf<String>
    public let hideView: PropertyOf<Bool>
    public var finishedAtIndex: Int?
    
    public init() {
        videoURL = currentVideo.map { $0?.url }
        isPlaying = PropertyOf(_isPlaying)
        unfinishedVideoDuration = PropertyOf(0, combineLatest(
            currentVideo.producer,
            playlist.producer
        ).map {currentVideo, playlist in
            let i = findVideo(currentVideo, inPlaylist: playlist) ?? 0
            return playlist[i..<playlist.count]
                .map { $0.duration }
                .reduce(0, combine: +)
        })
        currentVideoProgress = PropertyOf(0, combineLatest(
            currentVideo.producer,
            currentTime.producer
        ).map { video, time in
            video.map { Float(min(time / $0.duration, 1)) } ?? 0
        })
        totalDurationLeft = PropertyOf("", combineLatest(
            currentTime.producer,
            unfinishedVideoDuration.producer
        ).map { currentTime, unfinishedVideoDuration in
            let secondsLeft = Int(ceil(max(unfinishedVideoDuration - currentTime, 0)))
            return "\(secondsLeft)"
        })
        videos = ArrayProperty([])
        hideView = currentVideo.map { $0 == nil }
        hideOverlay = PropertyOf(true, combineLatest(
            isPlaying.producer,
            hideView.producer
        ).map { playing, hide in
            return playing || hide
        })
        
        // If we are at the end and new video arrives we'll automatically try to play it
        playlist.producer.startWithNext { [weak self] playlist in
            self?.videos.array = playlist
            if let this = self,
            let index = this.finishedAtIndex where index < playlist.count - 1 {
                this.seekVideo(playlist[index + 1])
            }
        }
    }
    
    public func prevVideo() -> MessageViewModel? {
        if currentVideo.value == nil {
            return playlist.value.last
        }
        return currentVideoIndex().flatMap {
            $0 > 0 ? $0 - 1 : nil
        }.map { playlist.value[$0] }
    }
    
    public func nextVideo() -> MessageViewModel? {
        if currentVideo.value == nil {
            return playlist.value.first
        }
        return currentVideoIndex().flatMap {
            $0 < playlist.value.count - 1 ? $0 + 1 : nil
        }.map { playlist.value[$0] }
    }
    
    public func nextUnreadVideo() -> MessageViewModel? {
        if playlist.value.count > 0 {
            let start = currentVideoIndex() ?? 0
            for video in playlist.value[start..<playlist.value.count] {
                if video.unread { return video }
            }
        }
        return nil
    }
    
    public func seekPrevVideo() -> Bool {
        return seekVideo(prevVideo())
    }
    
    public func seekVideoAtIndex(index: Int) -> Bool {
        return seekVideo(playlist.value[index])
    }
    
    public func seekNextVideo() -> Bool {
        let played = seekVideo(nextVideo())
        if !played {
            finishedAtIndex = playlist.value.count - 1
            delegate?.playerDidFinishPlaylist(self)
        }
        return played
    }
    
    public func seekNextUnreadVideo() -> Bool {
        let played = seekVideo(nextUnreadVideo())
        if !played {
            delegate?.playerDidFinishPlaylist(self)
        }
        return played
    }
    
    // MARK: - Hooks for PlayerViewController to update state
    
    public func updatePlaybackPosition(position: NSTimeInterval) {
        currentTime.value = position
    }
    
    public func updateIsPlaying(isPlaying: Bool) {
        _isPlaying.value = isPlaying
    }
    
    // MARK: - 
    
    private func seekVideo(video: MessageViewModel?) -> Bool {
        Log.debug("Will seek video with id \(video?.uniqueId) url: \(video?.url)")
        finishedAtIndex = nil
        if let v = currentVideo.value { delegate?.player(self, didPlayVideo: v) }
        currentTime.value = 0
        currentVideo.value = video
        if let v = video { delegate?.player(self, willPlayVideo: v) }
        return video != nil
    }
    
    private func currentVideoIndex() -> Int? {
        return findVideo(currentVideo.value, inPlaylist: playlist.value)
    }
}
