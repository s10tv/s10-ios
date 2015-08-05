//
//  PlayerViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/18/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Bond
import SCRecorder
import Async
import Core

class PlayerViewController : UIViewController {

    // TODO: Consider using AVQueuePlayer instead of SCPlayer for
    // gapless video playback
    @IBOutlet weak var playerView: SCVideoPlayerView!
    @IBOutlet weak var durationTimer: DurationTimer!
    @IBOutlet weak var overlay: UIView!
    @IBOutlet weak var volumeView: VolumeView!
    
    let vm = PlayerViewModel()
    var userPaused: Bool = false
    var player: SCPlayer { return playerView.player! }
    lazy var videoURLBond: Bond<NSURL?> = {
        return Bond<NSURL?> { [weak self] in
            // NOTE: Despite the fact that we are on main thread it appears that
            // because MutableProperty dispatch_sync to a different queue
            // AVPlayer.setItemByUrl ends up being a no-op. I can't explain it but
            // dispatching it again to main thread works around this issue.
            // the temp variable video is needed to avoid compiler crash
            let videoURL = $0
            Async.main { [weak self] in
                self?.player.setItemByUrl(videoURL)
//                Log.debug("set videoURL to \(videoURL)")
            }
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.playerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        player.delegate = self
        player.dyn("rate").producer.start(next: { [weak self] _ in
            self?.vm.updateIsPlaying(self?.player.isPlaying ?? false)
        })

        vm.hideView ->> view.dynHidden
        vm.videoURL ->> videoURLBond
        vm.isPlaying ->> overlay.dynHidden
        vm.totalDurationLeft ->> durationTimer.label
        
        vm.currentVideoProgress.producer.start(next: { [weak self] v in
            self?.durationTimer.progress = v
        })
        
        // Slight hack to get around the issue that playback momentarily stops when switching video
        vm.isPlaying.producer.start(next: { [weak self] in
            let isPlaying = $0
            UIView.animate(0.25, options: nil, delay: 0.25, animations: { [weak self] in
                self?.overlay.alpha = isPlaying ? 0 : 1
            })
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Async HACK to get around the issue that if we start player.play immediately
        // then checkMuteSwitch won't work because the silent audio will be interrupted by system
        volumeView.checkMuteSwitch()
        Async.main {
            self.player.beginSendingPlayMessages()
            if !self.userPaused { self.player.play() }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        player.endSendingPlayMessages()
        player.pause()
    }
    
    // MARK: -
    
    @IBAction func rewind() {
        if (player.currentTime().seconds < 2
            || player.itemDuration.seconds < 2
            || vm.videoURL.value == nil)
            && vm.prevVideo() != nil {
            vm.seekPrevVideo()
        } else {
            player.seekToTime(CMTimeMakeWithSeconds(0, 1))
            player.play()
        }
    }
    
    @IBAction func playOrPause() {
        player.isPlaying ? player.pause() : player.play()
        userPaused = !player.isPlaying
    }
    
    @IBAction func advance() {
        vm.seekNextVideo()
        Async.main { self.player.play() }
    }
}

extension PlayerViewController : SCPlayerDelegate {
    
    func player(player: SCPlayer, didPlay currentTime: CMTime, loopsCount: Int) {
        if !player.itemDuration.impliedValue && !currentTime.impliedValue {
            vm.updatePlaybackPosition(currentTime.seconds)
        }
    }
    
    func player(player: SCPlayer, didReachEndForItem item: AVPlayerItem) {
        advance()
    }
}

extension PlayerViewController : UIGestureRecognizerDelegate {
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}