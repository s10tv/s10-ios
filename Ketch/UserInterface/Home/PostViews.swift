//
//  PostViews.swift
//  Ketch
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import SDWebImage

class PostCell : UITableViewCell {
    
    @IBOutlet weak var coverFrameView: UIImageView!
    
    var post : Post? {
        didSet {
            coverFrameView.sd_setImageWithURL(post?.video?.coverFrameURL)
        }
    }

}

class PostHeaderView : UITableViewHeaderFooterView {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var timeDistanceLabel: UILabel!
    @IBOutlet weak var upvoteCountLabel: UILabel!

    var post : Post? {
        didSet {
            avatarView.sd_setImageWithURL(post?.author?.avatarURL)
            authorLabel.text = post?.author?.displayName
            timeDistanceLabel.text = "5m | 0.2miles"
            upvoteCountLabel.text = "\(post?.upvotes ?? 0)"
        }
    }
    
}