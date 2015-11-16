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
import ReactiveCocoa

class CandidateCell : UICollectionViewCell, BindableCell {
    typealias ViewModel = CandidateViewModel
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var serviceIconsView: UICollectionView!
    
    var cd: CompositeDisposable!
    
    func bind(vm: CandidateViewModel) {
        cd = CompositeDisposable()
        cd += serviceIconsView <~ (vm.profileIcons, ProfileIconCell.self)
        
        avatarView.sd_image.value = vm.avatar
        dateLabel.text = vm.displayDate
        nameLabel.text = vm.displayName
        reasonLabel.text = vm.reason
        
        serviceIconsView.invalidateIntrinsicContentSize()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cd.dispose()
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