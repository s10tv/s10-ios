//
//  HistoryCandidateCell.swift
//  S10
//
//  Created by Tony Xiao on 9/22/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation

import Foundation
import SDWebImage
import Core
import Bond
import ReactiveCocoa

class CandidateCell : UICollectionViewCell, BindableCell {
    typealias ViewModel = CandidateViewModel
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var serviceIconsView: UICollectionView!
    
    func bind(vm: CandidateViewModel) {
        avatarView.sd_setImageWithURL(vm.avatar?.url)
        dateLabel.text = vm.displayDate
        nameLabel.text = vm.displayName
        reasonLabel.text = vm.reason
        
        vm.profileIcons.map(serviceIconsView.factory(ProfileIconCell)) ->> serviceIconsView
        serviceIconsView.invalidateIntrinsicContentSize()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.image = nil
        avatarView.unbindDynImageURL()
        serviceIconsView.designatedBond.unbindAll()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
/// http://stackoverflow.com/questions/10133109/fastest-way-to-do-shadows-on-ios/10133182#10133182
/// Improve shadow performance, especially when scrolling
//        layer.shouldRasterize = true
//        layer.rasterizationScale = UIScreen.mainScreen().scale
    }
    
    static func reuseId() -> String {
        return reuseId(.CandidateCell)
    }
}