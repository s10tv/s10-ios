//
//  ProfileInfoCells.swift
//  S10
//
//  Created by Tony Xiao on 7/26/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
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
    
    var cd: CompositeDisposable!
    
    func bind(vm: TaylrProfileInfoViewModel) {
        cd = CompositeDisposable()
        cd.addDisposable { aboutLabel.rac_text <~ vm.about }
        cd.addDisposable { majorLabel.rac_text <~ vm.major }
        cd.addDisposable { hometownLabel.rac_text <~ vm.hometown }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cd.dispose()
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
    var cd: CompositeDisposable!
    
    func bind(vm: ConnectedProfileInfoViewModel) {
        self.vm = vm
        cd = CompositeDisposable()
        cd.addDisposable { collectionView <~ (vm.attributes, ProfileAttributeCell.self) }
        
        avatarView.sd_image.value = vm.avatar
        nameLabel.text = vm.displayName
        displayIdLabel.text = vm.displayId
        authenticatedIconView.image = vm.authenticatedIcon
        authenticatedIconView.tintColor = vm.themeColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cd.dispose()
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