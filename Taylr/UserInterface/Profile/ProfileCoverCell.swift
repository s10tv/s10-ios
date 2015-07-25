//
//  ProfileCoverCell.swift
//  S10
//
//  Created by Tony Xiao on 6/21/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Core
import Bond

class ProfileCoverCell : UITableViewCell {
    @IBOutlet weak var coverImageHeight: NSLayoutConstraint!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var coverOverlay: UIView!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    
    func bind(vm: UserViewModel) {
        (vm.avatar |> map { $0?.url }) ->> avatarView.dynImageURL
        (vm.cover |> map { $0?.url }) ->> coverImageView.dynImageURL
        vm.displayName ->> nameLabel
        vm.username ->> usernameLabel
        vm.distance ->> distanceLabel
        vm.lastActive ->> activityLabel
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        fatalError("ProfileCoverCell is not designed to be re-used")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.makeCircular()
        coverImageView.clipsToBounds = true
        avatarView.dynPlaceholderImage = avatarView.image
        coverImageView.dynPlaceholderImage = coverImageView.image
    }
}