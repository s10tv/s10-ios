//
//  ProfileSelectorCell.swift
//  S10
//
//  Created by Tony Xiao on 7/24/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Core

class ProfileSelectorCell : UICollectionViewCell {
    
    @IBOutlet weak var iconView: UIImageView!
    
    func bind(profile: UserViewModel.Profile) {
        iconView.bindImage(profile.icon)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconView.bindImage(nil)
    }
}