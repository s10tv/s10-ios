//
//  VideoPlayerViewController.swift
//  S10
//
//  Created by Tony Xiao on 10/9/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa
import SCRecorder

protocol VideoPlayerViewControllerDelegate : class {
    func videoPlayer(videoPlayer: VideoPlayerViewController, didPlayVideo video: Video)
    func videoPlayerDidFinishPlaylist(videoPlayer: VideoPlayerViewController)
}

class VideoPlayerViewController : UIViewController {
    
    // TODO: Consider using AVQueuePlayer instead of SCPlayer for
    // gapless video playback
    @IBOutlet weak var playerView: SCVideoPlayerView!
    @IBOutlet weak var durationTimer: DurationTimer!
    @IBOutlet weak var overlay: UIView!
    @IBOutlet weak var volumeView: VolumeView!
    
    weak var delegate: VideoPlayerViewControllerDelegate?
    
    var vm: VideoPlayerViewModel!
    var player: SCPlayer { return playerView.player! }
    var audioDisposable: Disposable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.playerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        player.delegate = self
        player.dyn("rate").producer.startWithNext { [weak self] _ in
            self?.vm.isPlaying.value = self?.player.isPlaying ?? false
        }
        
        overlay.rac_hidden <~ vm.isPlaying
        durationTimer.label.rac_text <~ vm.totalDurationLeft
        vm.currentVideo.producer.startWithNext { [weak self] message in
            let videoURL = message?.url
            // NOTE: Despite the fact that we are on main thread it appears that
            // because MutableProperty dispatch_sync to a different queue
            // AVPlayer.setItemByUrl ends up being a no-op. I can't explain it but
            // dispatching it again to main thread works around this issue.
            // the temp variable video is needed to avoid compiler crash
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                self?.player.setItemByUrl(videoURL)
                //                DDLogDebug("set videoURL to \(videoURL)")
            }
        }
        
        vm.currentVideoProgress.producer.startWithNext { [weak self] v in
            self?.durationTimer.progress = v
        }
        
        // Slight hack to get around the issue that playback momentarily stops when switching video
        vm.isPlaying.producer.startWithNext { [weak self] in
            let isPlaying = $0
            UIView.animateWithDuration(0.25, delay: 0.25, options: [], animations: { [weak self] in
                self?.overlay.alpha = isPlaying ? 0 : 1
            }, completion: nil)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        player.play()
        player.beginSendingPlayMessages()
        // Whenever user presses volume button we'll switch to an active audio category
        // so that there's sound
        audioDisposable = AudioController.sharedController.systemVolume.producer
            .skip(1)
            .startWithNext { _ in
                AudioController.sharedController.setAudioCategory(.PlaybackAndRecord)
            }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        player.endSendingPlayMessages()
        player.pause()
        audioDisposable?.dispose()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: -
    
    @IBAction func rewind() {
        player.seekToTime(CMTimeMakeWithSeconds(0, 1))
        player.play()
    }
    
    @IBAction func playOrPause() {
        player.isPlaying ? player.pause() : player.play()
    }
    
    @IBAction func advance() {
        if let video = vm.currentVideo.value {
            delegate?.videoPlayer(self, didPlayVideo: video)
        }
        if vm.seekNextVideo() {
            dispatch_async(dispatch_get_main_queue()) { self.player.play() }
        } else {
            delegate?.videoPlayerDidFinishPlaylist(self)
        }
    }
}

extension VideoPlayerViewController : SCPlayerDelegate {
    
    func player(player: SCPlayer, didPlay currentTime: CMTime, loopsCount: Int) {
        if !player.itemDuration.impliedValue && !currentTime.impliedValue {
            vm.currentVideoPosition.value = currentTime.seconds
        }
    }
    
    func player(player: SCPlayer, didReachEndForItem item: AVPlayerItem) {
        advance()
    }
}
