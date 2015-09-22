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
import Async
import Cartography
import Core

class ProfileSelectorCell : UICollectionViewCell, BindableCell {
    
    @IBOutlet weak var iconView: UIImageView!
    var vm: ProfileSelectorViewModel?
    
    override var selected: Bool {
        didSet {
            // TODO: Use UIImageView highlighted image...
            iconView.bindImage(selected ? vm?.icon : vm?.altIcon)
        }
    }
    
    func bind(vm: ProfileSelectorViewModel) {
        self.vm = vm
        iconView.bindImage(vm.altIcon)
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
    @IBOutlet weak var chatButton: UIButton!
    
    var vm: ProfileCoverViewModel!
    
    func bind(vm: ProfileCoverViewModel) {
        self.vm = vm
        vm.avatar ->> avatarView.imageBond
        vm.cover ->> coverImageView.imageBond
        vm.displayName ->> nameLabel
        vm.selectors.map(collectionView.factory(ProfileSelectorCell)) ->> collectionView
        chatButton.hidden = vm.hideChatButton
        // Cell is not available for immediate selection, therefore we'll wait for it to populate first
        Async.main {
            self.collectionView.selectItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0),
                        animated: false, scrollPosition: .None)
            
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
        // TODO: Use a better avatar placeholder
        avatarView.dynPlaceholderImage = avatarView.image
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
        Globals.analyticsService.screen("Connected Profiles", properties: [
            "integrationName": vm.selectedProfile.value.integrationName])
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
