//
//  PlayerViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/18/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import SCRecorder
import Async
import Bond
import Core

class PlayerViewController : UIViewController {

    // TODO: Consider using AVQueuePlayer instead of SCPlayer for
    // gapless video playback
    @IBOutlet weak var playerView: SCVideoPlayerView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var rewindImage: UIImageView!
    @IBOutlet weak var playPauseImage: UIImageView!
    @IBOutlet weak var skipImage: UIImageView!
    
    @IBOutlet var playbackControls: [UIImageView]!
    
    var interactor = PlayerInteractor()
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
        playerView.tapToPauseEnabled = true
        playerView.playerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerView.delegate = self
        player.delegate = self
        player.dyn("rate").producer.start(next: { [weak self] _ in
            self?.interactor.updateIsPlaying(self?.player.isPlaying ?? false)
        })
        
        interactor.videoURL ->> videoURLBond
        interactor.timestampText ->> timestampLabel
        interactor.durationText ->> durationLabel
        interactor.currentPercent ->> progressView
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        player.beginSendingPlayMessages()
        interactor.playNextVideo()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        player.endSendingPlayMessages()
    }
    
    // MARK: -
    
    func flashPlayPulseImage(image: UIImage?) {
        playPauseImage.image = image
        playPauseImage.alpha = 1
        UIView.animate(0.5, delay: 0.5) {
            self.playPauseImage.alpha = 0
        }
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
        interactor.playNextVideo()
    }
    
    @IBAction func didPanOnPlayer(pan: UIPanGestureRecognizer) {
        let view = pan.view!
        let percent = pan.translationInView(view).x / view.frame.width
        let threshold: CGFloat = 0.25
        let forwardScale = min(max(percent / threshold, 0), 1)
        let reverseScale = min(max(-percent / threshold, 0), 1)
        switch pan.state {
        case .Changed:
            skipImage.alpha = forwardScale
            rewindImage.alpha = reverseScale
            skipImage.transform = CGAffineTransform(scale: 1 + forwardScale)
            rewindImage.transform = CGAffineTransform(scale: 1 + reverseScale)
        case .Ended:
            if forwardScale == 1 {
                advance()
            } else if reverseScale == 1 {
                rewind()
            }
            fallthrough
        case .Cancelled:
            UIView.animate(0.25) {
                self.skipImage.alpha = 0
                self.rewindImage.alpha = 0
                self.skipImage.transform = CGAffineTransformIdentity
                self.rewindImage.transform = CGAffineTransformIdentity
            }
        default:
            break
        }
    }
}

extension PlayerViewController : SCVideoPlayerViewDelegate {
    func videoPlayerViewTappedToPlay(videoPlayerView: SCVideoPlayerView) {
        flashPlayPulseImage(UIImage(.icPlay))
    }
    
    func videoPlayerViewTappedToPause(videoPlayerView: SCVideoPlayerView) {
        flashPlayPulseImage(UIImage(.icPause))
    }
}

extension PlayerViewController : SCPlayerDelegate {
    
    func player(player: SCPlayer, didPlay currentTime: CMTime, loopsCount: Int) {
        if !player.itemDuration.impliedValue && !currentTime.impliedValue {
            interactor.updatePlaybackPosition(currentTime.seconds)
        }
    }
    
    func player(player: SCPlayer, didReachEndForItem item: AVPlayerItem) {
        interactor.playNextVideo()
    }
}

extension PlayerViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}