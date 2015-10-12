//
//  ProfileCoverCell.swift
//  S10
//
//  Created by Tony Xiao on 6/21/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import EDColor
import Async
import Cartography
import Core

class ProfileSelectorCell : UICollectionViewCell, BindableCell {
    
    @IBOutlet weak var iconView: UIImageView!
    var vm: ProfileSelectorViewModel?
    
    override var selected: Bool {
        didSet {
            // TODO: Use UIImageView highlighted image...
            iconView.sd_image.value = selected ? vm?.icon : vm?.altIcon
        }
    }
    
    func bind(vm: ProfileSelectorViewModel) {
        self.vm = vm
        iconView.sd_image.value = vm.altIcon
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let view = UIView(frame: bounds)
        let imageView = UIImageView(image: UIImage(named: "ic-up-triangle")!)
        view.addSubview(imageView)
        constrain(view, imageView) { view, imageView in
            imageView.bottom == view.bottom
            imageView.centerX == view.centerX
        }
        selectedBackgroundView = view
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
    @IBOutlet weak var collectionView: UICollectionView!
    
    var vm: ProfileCoverViewModel!
    var cd: CompositeDisposable!
    
    func bind(vm: ProfileCoverViewModel) {
        self.vm = vm
        cd = CompositeDisposable()
        cd += avatarView.sd_image <~ vm.avatar
        cd += coverImageView.sd_image <~ vm.cover
        cd += nameLabel.rac_text <~ vm.displayName
        cd += collectionView <~ (vm.selectors, ProfileSelectorCell.self)
        
        // Cell is not available for immediate selection, therefore we'll wait for it to populate first
        Async.main {
            self.collectionView.selectItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0),
                        animated: false, scrollPosition: .None)
            
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cd.dispose()
        fatalError("ProfileCoverCell is not designed to be re-used")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.makeCircular()
        coverImageView.clipsToBounds = true
        // TODO: Use a better avatar placeholder
        avatarView.sd_placeholderImage = avatarView.image
        coverImageView.sd_placeholderImage = coverImageView.image
        collectionView.delegate = self
    }
    
    static func reuseId() -> String {
        return reuseId(.ProfileCoverCell)
    }
}

extension ProfileCoverCell : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        vm.selectProfileAtIndex(indexPath.item)
        Analytics.track("Profile: Switch", [
            "Name": vm.selectedProfile.value.integrationName
        ])
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
