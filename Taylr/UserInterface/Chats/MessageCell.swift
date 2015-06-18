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

class MessageCell : UICollectionViewCell {
    
    @IBOutlet weak var playerView: SCVideoPlayerView!
    @IBOutlet weak var avatarView: UserAvatarView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var player: SCPlayer { return playerView.player }
    var message: Message? {
        didSet {
            player.setItemByUrl(message?.video?.URL)
            avatarView.user = message?.sender
            timeLabel.text = "2m"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        playerView.tapToPauseEnabled = true
        playerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        player.loopEnabled = true
        player.muted = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        player.setItem(nil)
    }
}