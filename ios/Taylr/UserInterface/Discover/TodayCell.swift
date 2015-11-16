//
//  CandidateCell.swift
//  Taylr
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Core

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
    
    var cd: CompositeDisposable!
    
    func bind(vm: TodayViewModel) {
        cd = CompositeDisposable()
        cd += messageButton.rac_title <~ vm.timeRemaining
        cd += serviceIconsView <~ (vm.profileIcons, ProfileIconCell.self)
        
        coverView.sd_image.value = vm.cover
        avatarView.sd_image.value = vm.avatar
        nameLabel.text = vm.displayName
        reasonLabel.rawText = vm.reason
        hometownLabel.text = vm.hometown
        majorLabel.text = vm.major
        
        serviceIconsView.invalidateIntrinsicContentSize()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cd.dispose()
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