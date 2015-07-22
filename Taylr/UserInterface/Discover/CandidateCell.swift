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
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var employerLabel: UILabel!
    @IBOutlet weak var serviceIconsView: UICollectionView!
    
    func bindViewModel(viewModel: CandidateViewModel) {
        viewModel.avatarURL ->> avatarView.dynImageURL
        viewModel.displayName ->> nameLabel
        let cells = DynamicArray([
            UIImage(.icTwitterSmall),
            UIImage(.icGithubSmall),
            UIImage(.icLinkedinSmall),
            UIImage(.icInstagramSmall)
        ]).map { (image, index) -> UICollectionViewCell in
            let cell = self.serviceIconsView.dequeueReusableCellWithReuseIdentifier("CandidateService", forIndexPath: NSIndexPath(forItem: index, inSection: 0)) as! CandidateServiceCell
            cell.imageView.image = image
            return cell
        }
        
        cells ->> serviceIconsView
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.image = nil
        avatarView.unbindDynImageURL()
        nameLabel.designatedBond.unbindAll()
        serviceIconsView.designatedBond.unbindAll()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.clipsToBounds = true
    }
}