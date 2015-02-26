//
//  ConnectionCell.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/4/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import SDWebImage
import DateTools

class ConnectionCell : UITableViewCell {
    
    @IBOutlet weak var newIndicator: UIImageView!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var connection : Connection? {
        didSet {
            reloadData()
        }
    }
    
    func reloadData() {
        
        let photos = connection?.user?.photos as [Photo]?
        if let avatar = photos?.first {
            avatarView.sd_setImageWithURL(NSURL(string: avatar.url))
        } else {
            avatarView.image = nil
        }
        
        // TODO: Can use connectionViewModel of sorts here
        nameLabel.text = connection?.user?.firstName
        timeLabel.text = connection?.updatedAt?.timeAgoSinceNow()
        newIndicator.hidden = !(connection?.hasUnreadMessage?.boolValue ?? false)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.makeCircular()
        newIndicator.makeCircular()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.sd_cancelCurrentImageLoad()
    }
}