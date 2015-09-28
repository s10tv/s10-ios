//
//  ProfileInfoCells.swift
//  S10
//
//  Created by Tony Xiao on 7/26/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Bond
import Core

class ProfileAttributeCell : UICollectionViewCell, BindableCell {
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var attrLabel: UILabel!
    
    func bind(vm: ConnectedProfileInfoViewModel.Attribute) {
        valueLabel.text = vm.value
        attrLabel.text = vm.label
    }
    
    static func reuseId() -> String {
        return reuseId(.ProfileAttributeCell)
    }
}

class TaylrProfileInfoCell : UITableViewCell, BindableCell {
    @IBOutlet weak var hometownLabel: UILabel!
    @IBOutlet weak var majorLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    
    func bind(vm: TaylrProfileInfoViewModel) {
        vm.about ->> aboutLabel.bnd_text
        vm.major ->> majorLabel.bnd_text
        vm.hometown ->> hometownLabel.bnd_text
    }
    
    static func reuseId() -> String {
        return reuseId(.TaylrProfileInfoCell)
    }
}

class ConnectedProfileInfoCell : UITableViewCell, BindableCell {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var displayIdLabel: UILabel!
    @IBOutlet weak var authenticatedIconView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var openButton: UIButton!
    
    private var vm: ConnectedProfileInfoViewModel!
    
    func bind(vm: ConnectedProfileInfoViewModel) {
        self.vm = vm
        avatarView.rac_image.value = vm.avatar
        nameLabel.text = vm.displayName
        displayIdLabel.text = vm.displayId
        authenticatedIconView.image = vm.authenticatedIcon
        authenticatedIconView.tintColor = vm.themeColor
        collectionView.bindTo(vm.attributes, cell: ProfileAttributeCell.self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        collectionView.unbind()
    }
    
    @IBAction func didTapOpen(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(vm.url)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.makeCircular()
        collectionView.delegate = self
    }
    
    static func reuseId() -> String {
        return reuseId(.ConnectedProfileInfoCell)
    }
}

// MARK: 3 column layout

extension ConnectedProfileInfoCell : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let columns = CGFloat(3)
        var size = layout.itemSize
        size.width = ((collectionView.bounds.width - layout.sectionInset.left - layout.sectionInset.right) - (layout.minimumInteritemSpacing) * (columns - 1)) / columns
        return size
    }
}