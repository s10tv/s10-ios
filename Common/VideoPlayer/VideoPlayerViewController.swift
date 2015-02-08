//
//  VideoPlayerViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import MediaPlayer

protocol VideoPlayerDelegate : class {
    func videoPlayerDidFinishPlayback(player: VideoPlayerViewController)
}

@objc(VideoPlayerViewController)
class VideoPlayerViewController : BaseViewController {
    var player = MPMoviePlayerController()
    weak var delegate : VideoPlayerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player.controlStyle = .None
        player.scalingMode = .AspectFill
        
        // Add to view hierarchy
        view.addSubview(player.view)
        player.view.makeEdgesEqualTo(view)
        
        listenForNotification(MPMoviePlayerPlaybackDidFinishNotification, object: player)
            .subscribeNextAs { [weak self] (notification: NSNotification) -> () in
            self?.delegate?.videoPlayerDidFinishPlayback(self!)
            return // Workaround for one statement implicit return
        }
    }

    func playVideoAtURL(videoURL: NSURL) {
        player.contentURL = videoURL
        player.play()
    }
    
    func stop() {
        player.stop()
    }
}
