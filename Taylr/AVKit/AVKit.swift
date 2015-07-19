//
//  AVKit.swift
//  S10
//
//  Created by Tony Xiao on 6/18/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import SCRecorder
import ReactiveCocoa
import Core

class AVKit {
    static let defaultFilters = AVKit.allFilters()
    
    class func allFilters() -> [SCFilter] {
        let emptyFilter = SCFilter.emptyFilter()
        emptyFilter.name = "#nofilter"
        return [
            SCFilter(CIFilterName: "CIPhotoEffectChrome"),
            SCFilter(CIFilterName: "CIPhotoEffectMono"),
            SCFilter(CIFilterName: "CIPhotoEffectFade"),
            SCFilter(CIFilterName: "CIPhotoEffectInstant"),
            SCFilter(CIFilterName: "CIPhotoEffectNoir"),
            SCFilter(CIFilterName: "CIPhotoEffectProcess"),
            SCFilter(CIFilterName: "CIPhotoEffectTonal"),
            SCFilter(CIFilterName: "CIPhotoEffectTransfer"),
            emptyFilter,
        ]
    }
}

struct PlayerVideoViewModel {
    let url: NSURL
    let duration: NSTimeInterval
    let timestamp: NSDate
    let avatarURL: NSURL
}

protocol PlayerInteractorDelegate {
    func didFinishVideo(video: PlayerVideoViewModel)
}

class PlayerInteractor {
    private let currentVideo = MutableProperty<PlayerVideoViewModel?>(nil)
    private let currentTime = MutableProperty<NSTimeInterval>(0)
    private let totalDuration = MutableProperty<NSTimeInterval>(0)
    private let _isPlaying = MutableProperty(false)
    var videoQueue: [PlayerVideoViewModel] = []
    
    let isPlaying: PropertyOf<Bool>
    let videoURL: PropertyOf<NSURL?>
    let avatarURL: PropertyOf<NSURL?>
    let timestampText: PropertyOf<String>
    let currentPercent: PropertyOf<Float>
    let durationText: PropertyOf<String>
    
    init() {
        isPlaying = PropertyOf(_isPlaying)
        videoURL = currentVideo |> map { $0?.url }
        avatarURL = currentVideo |> map { $0?.avatarURL }
        timestampText = currentVideo |> map {
            Formatters.formatInterval($0?.timestamp, relativeTo: NSDate()) ?? ""
        }
        durationText = PropertyOf("", combineLatest(
            currentTime.producer,
            totalDuration.producer
        ) |> map { current, total in
            assert(current <= total, "Expect current time to be less than total duration")
            return "\(Int(ceil(total - current)))"
        })
        currentPercent = PropertyOf(0, combineLatest(
            currentVideo.producer,
            currentTime.producer
        ) |> map { video, time in
            video.map { Float(time / $0.duration) } ?? 0
        })
    }
    
    func playNextVideo() {
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
