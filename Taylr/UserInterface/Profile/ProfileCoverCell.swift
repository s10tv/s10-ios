//
//  ProfileCoverCell.swift
//  S10
//
//  Created by Tony Xiao on 6/21/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Bond
import EDColor
import Core

class ProfileSelectorCell : UICollectionViewCell, BindableCell {
    
    @IBOutlet weak var iconView: UIImageView!
    var vm: ProfileSelectorViewModel!
    
    override var selected: Bool {
        didSet {
            iconView.tintColor = selected ? vm.color : UIColor(hex: 0x9B9B9B)
            iconView.image = iconView.image?.imageWithRenderingMode(.AlwaysTemplate)
        }
    }
    
    func bind(vm: ProfileSelectorViewModel) {
        self.vm = vm
        iconView.bindImage(vm.icon)
    }
    
    static func reuseId() -> String {
        return reuseId(.ProfileSelectorCell)
    }
}

class ProfileCoverCell : UITableViewCell, BindableCell {
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var coverOverlay: UIView!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var proximityLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var vm: ProfileCoverViewModel!
    
    func bind(vm: ProfileCoverViewModel) {
        self.vm = vm
        vm.avatar ->> avatarView.imageBond
        vm.cover ->> coverImageView.imageBond
        vm.firstName ->> nameLabel // TODO: should we show username?
        vm.lastName ->> usernameLabel
        vm.proximity ->> proximityLabel
        vm.selectors.map(collectionView.factory(ProfileSelectorCell)) ->> collectionView
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        fatalError("ProfileCoverCell is not designed to be re-used")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.makeCircular()
        coverImageView.clipsToBounds = true
//        avatarView.dynPlaceholderImage = avatarView.image // TODO: Use a better avatar placeholder
        coverImageView.dynPlaceholderImage = coverImageView.image
        collectionView.delegate = self
    }
    
    static func reuseId() -> String {
        return reuseId(.ProfileCoverCell)
    }
}

extension ProfileCoverCell : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        vm.selectProfileAtIndex(indexPath.item)
    }
}

// MARK: Center align profile selector icon cells

extension ProfileCoverCell : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let cellSpacing = layout.minimumInteritemSpacing
        let cellWidth = layout.itemSize.width
        let cellCount = CGFloat(collectionView.numberOfItemsInSection(section))
        let inset = (collectionView.bounds.width - cellCount * (cellWidth + cellSpacing)) * 0.5
        return UIEdgeInsets(top: 0, left: max(inset, 0), bottom: 0, right: 0)
    }
}
