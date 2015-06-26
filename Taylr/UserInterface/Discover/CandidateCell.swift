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
        didSet { if let u = candidate?.user { bindViewModel(u) } }
    }
    
    func bindViewModel(user: User) {
        user.avatarURL ->> avatarView.dynImageURL
        user.displayName ->> titleLabel
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.unbindDynImageURL()
        titleLabel.designatedBond.unbindAll()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.clipsToBounds = true
    }
}