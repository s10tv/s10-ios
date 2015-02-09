//
//  MessageCell.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/7/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation

class MessageCell : UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playIcon: UIImageView!
    
    var message : Message? {
        didSet {
            if let unread = message?.isUnread {
                playIcon.hidden = false
            } else {
                playIcon.hidden = true
            }
            imageView.sd_setImageWithURL(message?.thumbnailNSURL)
        }
    }
}
