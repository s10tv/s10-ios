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

class TodayCell: UICollectionViewCell, BindableCell {
    typealias ViewModel = TodayViewModel
    
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var majorLabel: UILabel!
    @IBOutlet weak var hometownLabel: UILabel!
    @IBOutlet weak var reasonLabel: DesignableLabel!
    @IBOutlet weak var serviceIconsView: UICollectionView!
    @IBOutlet weak var messageButton: UIButton!
    
    func bind(vm: TodayViewModel) {
        coverView.sd_setImageWithURL(vm.cover?.url)
        avatarView.sd_setImageWithURL(vm.avatar?.url)
        nameLabel.text = vm.displayName
        reasonLabel.rawText = vm.reason
        hometownLabel.text = vm.hometown
        majorLabel.text = vm.major
        vm.timeRemaining ->> messageButton.bnd_title
// MAJOR TODO: Make this work
//        vm.profileIcons.map(serviceIconsView.factory(ProfileIconCell)) ->> serviceIconsView
        serviceIconsView.invalidateIntrinsicContentSize()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.image = nil
        coverView.image = nil
        avatarView.unbindImage()
        coverView.unbindImage()
// MAJOR TODO: Make this work
//        serviceIconsView.designatedBond.unbindAll()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.makeCircular()
//        avatarView.clipsToBounds = true
/// http://stackoverflow.com/questions/10133109/fastest-way-to-do-shadows-on-ios/10133182#10133182
/// Improve shadow performance, especially when scrolling
//        layer.shouldRasterize = true
//        layer.rasterizationScale = UIScreen.mainScreen().scale
    }
    
    static func reuseId() -> String {
        return reuseId(.TodayCell)
    }
}