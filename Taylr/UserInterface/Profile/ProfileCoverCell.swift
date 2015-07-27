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

class ProfileCoverCell : UITableViewCell {
    @IBOutlet weak var coverImageHeight: NSLayoutConstraint!
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
        vm.selectorImages.map { [unowned self] (image, index) -> UICollectionViewCell in
            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier(.ProfileSelectorCell,
                forIndexPath: NSIndexPath(forItem: index, inSection: 0)) as! ProfileSelectorCell
            cell.iconView.bindImage(image)
            return cell
        }
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
}

class ProfileSelectorCell : UICollectionViewCell {
    
    @IBOutlet weak var iconView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconView.bindImage(nil)
    }
}