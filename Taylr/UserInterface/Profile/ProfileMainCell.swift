//
//  ProfileMainCell.swift
//  S10
//
//  Created by Tony Xiao on 6/21/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Core
import Bond

class ProfileMainCell : UITableViewCell {
    @IBOutlet weak var coverImageHeight: NSLayoutConstraint!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avatarView: UserAvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var aboutLabel: DesignableLabel!
    
    var user: User! {
        didSet {
            if let user = user {
//                coverImageView.image =
//                distanceLabel.text
//                activityLabel.text
                avatarView.user = user
                user.coverURL ->> coverImageView.dynImageURL
                user.displayName ->> nameLabel
                user.dynUsername.map { $0 ?? "" } ->> usernameLabel
                aboutLabel.rawText = user.about // TODO: Add Dynamic Bond here
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        coverImageView.clipsToBounds = true
        avatarView.dynPlaceholderImage = avatarView.image
        coverImageView.dynPlaceholderImage = coverImageView.image
    }
    
}