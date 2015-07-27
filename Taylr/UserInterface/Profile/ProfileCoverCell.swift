//
//  ProfileCoverCell.swift
//  S10
//
//  Created by Tony Xiao on 6/21/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Core
import Bond

class ProfileCoverCell : UITableViewCell, BindableCell {
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var coverOverlay: UIView!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var proximityLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    func bind(vm: ProfileCoverViewModel) {
        vm.avatar ->> avatarView.imageBond
        vm.cover ->> coverImageView.imageBond
        vm.firstName ->> nameLabel // TODO: should we show username?
        vm.lastName ->> usernameLabel
        vm.proximity ->> proximityLabel
        vm.selectorImages.map(collectionView.factory(ProfileSelectorCell)) ->> collectionView
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
    }
    
    static func reuseId() -> String {
        return reuseId(.ProfileCoverCell)
    }
}

class ProfileSelectorCell : UICollectionViewCell, BindableCell {
    typealias ViewModel = Image
    
    @IBOutlet weak var iconView: UIImageView!
    
    func bind(vm: ViewModel) {
        iconView.bindImage(vm)
    }
    
    static func reuseId() -> String {
        return reuseId(.ProfileSelectorCell)
    }
}