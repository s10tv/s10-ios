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
    @IBOutlet weak var avatarView: UserAvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    var connection : Connection? {
        didSet {
            reloadData()
        }
    }
    
    func reloadData() {
        
        let photos = connection?.user?.photos as [Photo]?
        avatarView.user = connection?.user
        avatarView.fadeRatio = connection?.fractionExpired.f ?? 0
        
        // TODO: Can use connectionViewModel of sorts here
        nameLabel.text = connection?.user?.firstName
        subtitleLabel.text = connection?.lastMessageText
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