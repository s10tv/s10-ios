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

class TaylrProfileInfoCell : UITableViewCell, BindableCell {
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    
    func bind(vm: TaylrProfileInfoViewModel) {
        vm.tagline ->> taglineLabel
        vm.about ->> aboutLabel
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
    
    var vm: ConnectedProfileInfoViewModel!
    
    func bind(vm: ConnectedProfileInfoViewModel) {
        self.vm = vmt
        avatarView.bindImage(vm.avatar)
        nameLabel.text = vm.displayName
        displayIdLabel.text = vm.displayId
        authenticatedIconView.image = vm.authenticatedIcon
        authenticatedIconView.tintColor = vm.themeColor
        vm.attributes.map(collectionView.factory(ProfileAttributeCell)) ->> collectionView
    }
    
    @IBAction func didTapOpen(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(vm.url)
    }
    
    static func reuseId() -> String {
        return reuseId(.ConnectedProfileInfoCell)
    }
}

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