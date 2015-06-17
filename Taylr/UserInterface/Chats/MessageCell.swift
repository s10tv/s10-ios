//
//  MessageCell.swift
//  Taylr
//
//  Created by Tony Xiao on 6/14/15.
//  Copyright (c) 2015 Taylr. All rights reserved.
//

import Foundation
import SDWebImage
import MediaPlayer
import Core

class MessageCell : UICollectionViewCell {
    
    @IBOutlet weak var coverFrameView: UIImageView!
    lazy var player = MPMoviePlayerController()
    
    var message: Message? {
        didSet {
            coverFrameView.sd_setImageWithURL(message?.video?.coverFrameURL)
        }
    }
    
    @IBAction func togglePlayback(sender: AnyObject) {
        if player.contentURL == nil {
            addSubview(player.view)
            player.view.makeEdgesEqualTo(self)
            player.contentURL = message?.video?.URL
        }
        if player.playbackState != .Playing {
            player.play()
        } else {
            player.stop()
        }
    }
}