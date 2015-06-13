//
//  CandidateCell.swift
//  Ketch
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import SDWebImage

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