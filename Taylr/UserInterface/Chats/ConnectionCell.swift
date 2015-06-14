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
    
    @IBOutlet weak var avatarView: UserAvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    var connection : Connection? {
        didSet {
            reloadData()
        }
    }
    
    func reloadData() {
        avatarView.user = connection?.otherUser
        
        // TODO: Can use connectionViewModel of sorts here
        nameLabel.text = connection?.otherUser?.displayName
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.sd_cancelCurrentImageLoad()
    }
}