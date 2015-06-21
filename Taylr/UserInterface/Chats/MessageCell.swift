//
//  MessageCell.swift
//  Taylr
//
//  Created by Tony Xiao on 6/14/15.
//  Copyright (c) 2015 Taylr. All rights reserved.
//

import Foundation
import SDWebImage
import SCRecorder
import Core

protocol MessageCellDelegate : NSObjectProtocol {
    func messageCell(cell: MessageCell, didPlayMessage message: MessageViewModel)
}

class MessageCell : UICollectionViewCell {
    
    @IBOutlet weak var playerView: SCVideoPlayerView!
    @IBOutlet weak var avatarView: UserAvatarView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    private var player: SCPlayer { return playerView.player }
    weak var delegate: MessageCellDelegate?
    var message: MessageViewModel? {
        didSet {
            player.setItemByUrl(message?.videoURL)
            avatarView.user = message?.sender
            statusLabel.text = message?.statusText
            timeLabel.text = message?.dateText
            durationLabel.text = nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        playerView.tapToPauseEnabled = true
        playerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerView.delegate = self
        player.delegate = self
        prepareForReuse()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        message = nil
    }
    
    func restoreInfo() {
        [avatarView, statusLabel, timeLabel].each {
            $0.setHiddenAnimated(hidden: false, duration: 0, delay: 0)
        }
    }
    
    func fadeInfoOut() {
        [avatarView, statusLabel, timeLabel].each {
            $0.setHiddenAnimated(hidden: false, duration: 0, delay: 0)
            $0.setHiddenAnimated(hidden: true, duration: 0.5, delay: 2)
        }
    }
    
    func playVideo() {
        player.play()
        player.beginSendingPlayMessages()
        fadeInfoOut()
    }
    
    func pauseVideo() {
        player.endSendingPlayMessages()
        player.pause()
    }
}

extension MessageCell : SCPlayerDelegate {
    func player(player: SCPlayer!, didReachEndForItem item: AVPlayerItem!) {
        delegate?.messageCell(self, didPlayMessage: message!)
    }
    
    func player(player: SCPlayer!, didPlay currentTime: CMTime, loopsCount: Int) {
        let secondsRemaining = Int(ceil(player.itemDuration.seconds - currentTime.seconds))
        durationLabel.text = "\(secondsRemaining)"
        statusLabel.text = message?.statusText
    }
}

extension MessageCell : SCVideoPlayerViewDelegate {
    
    func videoPlayerViewTappedToPause(videoPlayerView: SCVideoPlayerView!) {
//        restoreInfo()
    }

    func videoPlayerViewTappedToPlay(videoPlayerView: SCVideoPlayerView!) {
//        fadeInfoOut()
    }
}