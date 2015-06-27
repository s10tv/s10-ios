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
import Bond

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
            if let message = message {
                println("\(message.sender) \(message.message?.connection)")
                avatarView.user = message.sender
                player.setItemByUrl(message.videoURL.value)
                message.formattedDate ->> timeLabel
                message.formattedStatus ->> statusLabel
            }
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
        durationLabel.text = nil
        unbindAll(timeLabel, statusLabel)
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
    
    func cellWillAppear() {
        playVideo()
    }
    
    func cellDidDisappear() {
        pauseVideo()
    }
    
    func playVideo() {
        player.play()
        player.beginSendingPlayMessages()
//        fadeInfoOut()
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
        if !player.itemDuration.impliedValue && !currentTime.impliedValue {
            let secondsRemaining = Int(ceil(player.itemDuration.seconds - currentTime.seconds))
            durationLabel.text = "\(secondsRemaining)"
        }
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