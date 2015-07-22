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
    @IBOutlet weak var subtitleLabel: UILabel!
    
    func bindViewModel(viewModel: CandidateViewModel) {
        viewModel.avatarURL ->> avatarView.dynImageURL
        viewModel.displayName ->> titleLabel
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        avatarView.image = nil
        avatarView.unbindDynImageURL()
        titleLabel.designatedBond.unbindAll()
        subtitleLabel.designatedBond.unbindAll()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.clipsToBounds = true
//        clipsToBounds = false
//        layer.shadowColor = UIColor.blackColor().CGColor // (StyleKit.candidateShadow.shadowColor as? UIColor)?.CGColor
//        layer.shadowOffset = StyleKit.candidateShadow.shadowOffset
//        layer.shadowRadius = StyleKit.candidateShadow.shadowBlurRadius
    }
}