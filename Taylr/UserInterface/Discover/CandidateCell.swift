//
//  CandidateCell.swift
//  Taylr
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import SDWebImage
import Core

class CandidateCell : UICollectionViewCell {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var candidate: Candidate? {
        didSet {
            avatarView.sd_setImageWithURL(candidate?.user?.avatarURL)
            titleLabel.text = candidate?.user?.displayName
        }
    }
}