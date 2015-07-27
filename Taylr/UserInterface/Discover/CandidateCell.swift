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
import ReactiveCocoa

class CandidateCell : UICollectionViewCell, BindableCell {
    typealias ViewModel = CandidateViewModel
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var employerLabel: UILabel!
    @IBOutlet weak var serviceIconsView: UICollectionView!
    
    func bind(vm: CandidateViewModel) {
        avatarView.sd_setImageWithURL(vm.avatar?.url)
        nameLabel.text = vm.displayName
        jobTitleLabel.text = vm.jobTitle
        employerLabel.text = vm.employer
        
        let array = DynamicArray([
            UIImage(.icTwitterSmall),
            UIImage(.icGithubSmall),
            UIImage(.icLinkedinSmall),
            UIImage(.icInstagramSmall)
        ])
        array.map(
            serviceIconsView.factory(CandidateServiceCell)
        ) ->> serviceIconsView
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.image = nil
        avatarView.unbindDynImageURL()
        nameLabel.designatedBond.unbindAll()
        jobTitleLabel.designatedBond.unbindAll()
        employerLabel.designatedBond.unbindAll()
        serviceIconsView.designatedBond.unbindAll()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.clipsToBounds = true
        /// http://stackoverflow.com/questions/10133109/fastest-way-to-do-shadows-on-ios/10133182#10133182
        /// Improve shadow performance, especially when scrolling
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
    }
    
    static func reuseId() -> String {
        return reuseId(.CandidateCell)
    }
}