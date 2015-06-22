//
//  ProfileMainCell.swift
//  S10
//
//  Created by Tony Xiao on 6/21/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Core

class ProfileMainCell : UITableViewCell {
    @IBOutlet weak var coverImageHeight: NSLayoutConstraint!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avatarView: UserAvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var aboutLabel: DesignableLabel!
    
    var user: User? {
        didSet {
//            coverImageView.image = 
            avatarView.user = user
            nameLabel.text = user?.displayName
//            usernameLabel.text 
//            distanceLabel.text
//            activityLabel.text
            aboutLabel.rawText = user?.about
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        coverImageView.clipsToBounds = true
    }
    
}