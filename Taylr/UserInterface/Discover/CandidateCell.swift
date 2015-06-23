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
import Bond

class CandidateCell : UICollectionViewCell {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var candidate: Candidate? {
        didSet {
            avatarView.sd_setImageWithURL(candidate?.user?.dynAvatarURL.value)
            (candidate?.user?.dynDisplayName).map { $0 ->> self.titleLabel }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.designatedBond.unbindAll()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.clipsToBounds = true
    }
}