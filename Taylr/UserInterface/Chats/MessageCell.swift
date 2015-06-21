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
    @IBOutlet weak var timeLabel: UILabel!
    
    weak var delegate: MessageCellDelegate?
    var player: SCPlayer { return playerView.player }
    var message: MessageViewModel? {
        didSet {
            player.setItemByUrl(message?.videoURL)
            avatarView.user = message?.sender
            timeLabel.text = "2m"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        playerView.tapToPauseEnabled = true
        playerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
//        player.loopEnabled = true
        player.delegate = self
//        player.muted = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        player.setItem(nil)
    }
}

extension MessageCell : SCPlayerDelegate {
    func player(player: SCPlayer!, didReachEndForItem item: AVPlayerItem!) {
        delegate?.messageCell(self, didPlayMessage: message!)
    }
}