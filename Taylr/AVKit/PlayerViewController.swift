//
//  PlayerViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/18/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import SCRecorder
import Async
import Bond
import Core

class PlayerViewController : UIViewController {

    // TODO: Consider using AVQueuePlayer instead of SCPlayer for
    // gapless video playback
    @IBOutlet weak var playerView: SCVideoPlayerView!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var playPauseButton: UIButton!
    
    @IBOutlet var playbackControls: [UIButton]!
    
    var interactor: PlayerInteractor!
    var player: SCPlayer { return playerView.player! }
    lazy var videoURLBond: Bond<NSURL?> = {
        return Bond<NSURL?> {
            // NOTE: Despite the fact that we are on main thread it appears that
            // because MutableProperty dispatch_sync to a different queue
            // AVPlayer.setItemByUrl ends up being a no-op. I can't explain it but
            // dispatching it again to main thread works around this issue.
            // the temp variable video is needed to avoid compiler crash
            let videoURL = $0
            Async.main {
                Log.info("Playing video at url \(videoURL)")
                self.player.setItemByUrl(videoURL)
                self.player.play()
            }
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarView.makeCircular()
        playerView.tapToPauseEnabled = true
        playerView.playerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerView.delegate = self
        player.delegate = self
        player.dyn("rate").producer.start(next: { [weak self] _ in
            self?.interactor.updateIsPlaying(self?.player.isPlaying ?? false)
        })
        
        interactor.videoURL ->> videoURLBond
        interactor.avatarURL ->> avatarView.dynImageURL
        interactor.timestampText ->> timestampLabel
        interactor.durationText ->> durationLabel
        interactor.currentPercent ->> progressView
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        player.beginSendingPlayMessages()
        interactor.playNextVideo()
//        playbackControls.each {
//            $0.setHiddenAnimated(hidden: true, duration: 0.5, delay: 1)
//        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        player.endSendingPlayMessages()
    }
    
    // MARK: -
    
    @IBAction func didTapRewind(sender: AnyObject) {
        player.seekToTime(CMTimeMakeWithSeconds(0, 1))
        player.play()
    }

    @IBAction func didTapPlayOrPause(sender: AnyObject) {
        player.isPlaying ? player.pause() : player.play()
    }
    
    @IBAction func didTapSkip(sender: AnyObject) {
        interactor.playNextVideo()
    }
}

extension PlayerViewController : SCVideoPlayerViewDelegate {
    func videoPlayerViewTappedToPlay(videoPlayerView: SCVideoPlayerView) {
    }
    
    func videoPlayerViewTappedToPause(videoPlayerView: SCVideoPlayerView) {
        
    }
}

extension PlayerViewController : SCPlayerDelegate {
    
    func player(player: SCPlayer, itemReadyToPlay item: AVPlayerItem) {
        
    }
    
    func player(player: SCPlayer, didPlay currentTime: CMTime, loopsCount: Int) {
        if !player.itemDuration.impliedValue && !currentTime.impliedValue {
            interactor.updatePlaybackPosition(currentTime.seconds)
        }
    }
    
    func player(player: SCPlayer, didReachEndForItem item: AVPlayerItem) {
        interactor.playNextVideo()
    }
}