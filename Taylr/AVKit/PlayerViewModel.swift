//
//  PlayerViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/20/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Core

protocol PlayableVideo {
    var uniqueId: String { get }
    var url: NSURL { get }
    var duration: NSTimeInterval { get }
}

protocol PlayerDelegate : class {
    func playerDidFinishPlaylist(player: PlayerViewModel)
    func player(player: PlayerViewModel, willPlayVideo video: PlayableVideo)
    func player(player: PlayerViewModel, didPlayVideo video: PlayableVideo)
}

private func findVideo(video: PlayableVideo?, inPlaylist playlist: [PlayableVideo]) -> Int? {
    for (index, v) in enumerate(playlist) {
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
class PlayerViewModel {
    private let currentVideo = MutableProperty<PlayableVideo?>(nil)
    private let currentTime = MutableProperty<NSTimeInterval>(0)
    private let _isPlaying = MutableProperty(false)
    private let unfinishedVideoDuration: PropertyOf<NSTimeInterval>
    weak var delegate: PlayerDelegate?
    
    let playlist = MutableProperty<[PlayableVideo]>([])
    let videoURL: PropertyOf<NSURL?>
    let isPlaying: PropertyOf<Bool>
    let currentVideoProgress: PropertyOf<Float>
    let totalDurationLeft: PropertyOf<String>
    
    init() {
        videoURL = currentVideo |> map { $0?.url }
        isPlaying = PropertyOf(_isPlaying)
        unfinishedVideoDuration = PropertyOf(0, combineLatest(
            currentVideo.producer,
            playlist.producer
        ) |> map {currentVideo, playlist in
            let i = findVideo(currentVideo, inPlaylist: playlist) ?? 0
            return playlist[i..<playlist.count]
                .map { $0.duration }
                .reduce(0, combine: +)
        })
        currentVideoProgress = PropertyOf(0, combineLatest(
            currentVideo.producer,
            currentTime.producer
        ) |> map { video, time in
            video.map { Float(time / $0.duration) } ?? 0
        })
        totalDurationLeft = PropertyOf("", combineLatest(
            currentTime.producer,
            unfinishedVideoDuration.producer
        ) |> map { currentTime, unfinishedVideoDuration in
            let secondsLeft = Int(ceil(max(unfinishedVideoDuration - currentTime, 0)))
            return "\(secondsLeft)"
        })
    }
    
    func prevVideo() -> PlayableVideo? {
        return currentVideoIndex().flatMap {
            $0 > 0 ? $0 - 1 : nil
        }.map { playlist.value[$0] }
    }
    
    func nextVideo() -> PlayableVideo? {
        return currentVideoIndex().flatMap {
            $0 < playlist.value.count - 1 ? $0 + 1 : nil
        }.map { playlist.value[$0] } ?? playlist.value.first
    }
    
    func playPrevVideo() {
        playVideo(prevVideo())
    }
    
    func playNextVideo() {
        if !playVideo(nextVideo()) {
            delegate?.playerDidFinishPlaylist(self)
        }
    }
    
    // MARK: - Hooks for PlayerViewController to update state
    
    func updatePlaybackPosition(position: NSTimeInterval) {
        currentTime.value = position
    }
    
    func updateIsPlaying(isPlaying: Bool) {
        _isPlaying.value = isPlaying
    }
    
    // MARK: - 
    
    private func playVideo(video: PlayableVideo?) -> Bool {
        Log.debug("Will play video with id \(video?.uniqueId) url: \(video?.url)")
        currentVideo.value.map { delegate?.player(self, didPlayVideo: $0) }
        currentTime.value = 0
        currentVideo.value = video
        video.map { delegate?.player(self, willPlayVideo: $0) }
        return video != nil
    }
    
    private func currentVideoIndex() -> Int? {
        return findVideo(currentVideo.value, inPlaylist: playlist.value)
    }
}
