//
//  PlayerInteractor.swift
//  S10
//
//  Created by Tony Xiao on 7/20/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Core

protocol PlayableVideo {
    var url: NSURL { get }
    var duration: NSTimeInterval { get }
    var timestamp: NSDate { get }
}

protocol PlayerInteractorDelegate : class {
    func player(interactor: PlayerInteractor, didFinishVideo video: PlayableVideo)
}

class PlayerInteractor {
    private let currentVideo = MutableProperty<PlayableVideo?>(nil)
    private let currentTime = MutableProperty<NSTimeInterval>(0)
    private let totalDuration = MutableProperty<NSTimeInterval>(0)
    private let _isPlaying = MutableProperty(false)
    var videoQueue: [PlayableVideo] = []
    weak var delegate: PlayerInteractorDelegate?
    
    let isPlaying: PropertyOf<Bool>
    let videoURL: PropertyOf<NSURL?>
    let timestampText: PropertyOf<String>
    let currentPercent: PropertyOf<Float>
    let durationText: PropertyOf<String>
    
    init() {
        isPlaying = PropertyOf(_isPlaying)
        videoURL = currentVideo |> map { $0?.url }
        timestampText = currentVideo |> map {
            Formatters.formatInterval($0?.timestamp, relativeTo: NSDate()) ?? ""
        }
        durationText = PropertyOf("", combineLatest(
            currentTime.producer,
            totalDuration.producer
        ) |> map { current, total in
            let secondsLeft = Int(ceil(max(total - current, 0)))
            return "\(secondsLeft)"
        })
        currentPercent = PropertyOf(0, combineLatest(
            currentVideo.producer,
            currentTime.producer
        ) |> map { video, time in
            video.map { Float(time / $0.duration) } ?? 0
        })
    }
    
    func playNextVideo() {
        if let video = currentVideo.value {
            delegate?.player(self, didFinishVideo: video)
        }
        if videoQueue.count > 0 {
            currentVideo.value = videoQueue.removeAtIndex(0)
        } else {
            currentVideo.value = nil
        }
        currentTime.value = 0
        totalDuration.value = videoQueue.map { $0.duration }.reduce(0, combine: +)
                            + (currentVideo.value?.duration ?? 0)
    }
    
    // Hooks for PlayerViewController to update state
    
    func updatePlaybackPosition(position: NSTimeInterval) {
        currentTime.value = position
    }
    
    func updateIsPlaying(isPlaying: Bool) {
        _isPlaying.value = isPlaying
    }
}
