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

struct PlayerViewModel {
    private let currentVideo = MutableProperty<PlayableVideo?>(nil)
    private let currentTime = MutableProperty<NSTimeInterval>(0)
    private let _isPlaying = MutableProperty(false)
    private let totalDuration: PropertyOf<NSTimeInterval>
    weak var delegate: PlayerDelegate?
    
    let playlist = MutableProperty<[PlayableVideo]>([])
    let isPlaying: PropertyOf<Bool>
    let videoURL: PropertyOf<NSURL?>
    let currentVideoProgress: PropertyOf<Float>
    let totalDurationLeft: PropertyOf<String>
    
    init() {
        isPlaying = PropertyOf(_isPlaying)
        videoURL = currentVideo |> map { $0?.url }
        totalDuration = playlist |> map {
            return $0.map { $0.duration }.reduce(0, combine: +)
        }
        currentVideoProgress = PropertyOf(0, combineLatest(
            currentVideo.producer,
            currentTime.producer
        ) |> map { video, time in
            video.map { Float(time / $0.duration) } ?? 0
        })
        totalDurationLeft = PropertyOf("", combineLatest(
            currentTime.producer,
            totalDuration.producer
        ) |> map { current, total in
            let secondsLeft = Int(ceil(max(total - current, 0)))
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
            $0 < playlist.value.count ? $0 + 1 : nil
        }.map { playlist.value[$0] }
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
        currentVideo.value.map { delegate?.player(self, didPlayVideo: $0) }
        currentTime.value = 0
        currentVideo.value = video
        video.map { delegate?.player(self, willPlayVideo: $0) }
        return video != nil
    }
    
    private func currentVideoIndex() -> Int? {
        for (index, video) in enumerate(playlist.value) {
            if video.uniqueId == currentVideo.value?.uniqueId {
                return index
            }
        }
        return nil
    }
}
