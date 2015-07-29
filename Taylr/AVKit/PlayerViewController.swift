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
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var overlay: UIView!
    
    let vm = PlayerViewModel()
    var player: SCPlayer { return playerView.player! }
    lazy var videoURLBond: Bond<NSURL?> = {
        return Bond<NSURL?> {
            // NOTE: Despite the fact that we are on main thread it appears that
            // because MutableProperty dispatch_sync to a different queue
            // AVPlayer.setItemByUrl ends up being a no-op. I can't explain it but
            // dispatching it again to main thread works around this issue.
            // the temp variable video is needed to avoid compiler crash
            let videoURL = $0
            Async.main { [weak self] in
                Log.info("Playing video at url \(videoURL)")
                self?.player.setItemByUrl(videoURL)
                self?.player.play()
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
        
        vm.videoURL ->> videoURLBond
        vm.totalDurationLeft ->> durationLabel
        vm.currentVideoProgress ->> progressView
        vm.isPlaying ->> overlay.dynHidden
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        player.beginSendingPlayMessages()
        vm.playNextVideo()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        player.endSendingPlayMessages()
    }
    
    // MARK: -
    
    @IBAction func rewind() {
        if (player.currentTime().seconds < 2 || player.itemDuration.seconds < 2)
            && vm.prevVideo() != nil {
            vm.playPrevVideo()
        } else {
            player.seekToTime(CMTimeMakeWithSeconds(0, 1))
            player.play()
        }
    }
    
    @IBAction func playOrPause() {
        player.isPlaying ? player.pause() : player.play()
    }
    
    @IBAction func advance() {
        vm.playNextVideo()
    }
}

extension PlayerViewController : SCPlayerDelegate {
    
    func player(player: SCPlayer, didPlay currentTime: CMTime, loopsCount: Int) {
        if !player.itemDuration.impliedValue && !currentTime.impliedValue {
            vm.updatePlaybackPosition(currentTime.seconds)
        }
    }
    
    func player(player: SCPlayer, didReachEndForItem item: AVPlayerItem) {
        vm.playNextVideo()
    }
}

extension PlayerViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}