//
//  VideoPlayerViewModel.swift
//  S10
//
//  Created by Tony Xiao on 10/8/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import LayerKit
import ReactiveCocoa

public class VideoPlayerViewModel {
    private let ctx: Context
    
    public let playlist: ArrayProperty<Video>
    public let totalDurationLeft: PropertyOf<String>
    public let currentVideo: PropertyOf<Video?>
    public let currentVideoProgress: PropertyOf<Float>
    public let currentVideoPosition = MutableProperty<NSTimeInterval>(0)
    public let isPlaying = MutableProperty(false)
    
    init(_ ctx: Context, videos: [Video]? = nil) {
        self.ctx = ctx
        playlist = ArrayProperty(videos ?? [])
        currentVideo = PropertyOf(nil, playlist.producer.map { $0.first }
            .skipRepeats { $0?.identifier == $1?.identifier })
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
    
    public func seekNextVideo() -> Video? {
        return playlist.dequeue()
    }
}

