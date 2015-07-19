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

class PlayerViewController : UIViewController {

    @IBOutlet weak var playerView: SCVideoPlayerView!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var totalDurationLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    var player: SCPlayer { return playerView.player! }
    var interactor: PlayerInteractor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.tapToPauseEnabled = true
        playerView.playerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerView.delegate = self
        player.delegate = self
        interactor.currentVideo.producer.start(next: { [weak self] in
            // NOTE: Despite the fact that we are on main thread it appears that
            // because MutableProperty dispatch_sync to a different queue
            // AVPlayer.setItemByUrl ends up being a no-op. I can't explain it but
            // dispatching it again to main thread works around this issue.
            // the temp variable video is needed to avoid compiler crash
            let video = $0
            Async.main {
                println("Playing video at url \(video?.url)")
                self?.player.setItemByUrl(video?.url)
                self?.player.play()
            }
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        interactor.playNextVideo()
    }
    
    @IBAction func didTapRewind(sender: AnyObject) {
        
    }

    @IBAction func didTapPlayOrPause(sender: AnyObject) {
        
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
    func player(player: SCPlayer, didReachEndForItem item: AVPlayerItem) {
        interactor.playNextVideo()
    }
}