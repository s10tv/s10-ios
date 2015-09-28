//
//  ConnectionCell.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/4/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Bond
import JSBadgeView
import Core

class ContactConnectionCell : UITableViewCell, BindableCell {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var rightArrow: UIImageView!
    var badgeView: JSBadgeView!
    
    func bind(vm: ContactConnectionViewModel) {
        avatarView.rac_image <~ vm.avatar
        vm.displayName ->> nameLabel.bnd_text
        vm.busy ->> spinner.bnd_animating
        vm.statusMessage ->> subtitleLabel.bnd_text
        vm.hideRightArrow ->> rightArrow.bnd_hidden
        badgeView.rac_badgeText <~ vm.badgeText
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // MAJOR TODO: Figure out how to unbind
//        [nameLabel, subtitleLabel].each {
//            $0.designatedBond.unbindAll()
//        }
//        badgeView.designatedBond.unbindAll()
//        spinner.designatedBond.unbindAll()
//        rightArrow.dynHidden.valueBond.unbindAll()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.makeCircular()
        badgeView = JSBadgeView(parentView: self, alignment: .CenterRight)
        badgeView.badgeTextFont = UIFont(.cabinRegular, size: 12)
        badgeView.badgeStrokeWidth = 5
        badgeView.badgeStrokeColor = StyleKit.brandPurple
        badgeView.badgeBackgroundColor = StyleKit.brandPurple
        badgeView.badgePositionAdjustment = CGPoint(x: -22, y: 0)
    }
    
    static func reuseId() -> String {
        return reuseId(.ContactConnectionCell)
    }
}

class NewConnectionCell : UITableViewCell, BindableCell {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var playIcon: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var profileIconsView: UICollectionView!
 
    func bind(vm: NewConnectionViewModel) {
        avatarView.rac_image <~ vm.avatar
        vm.displayName ->> nameLabel.bnd_text
        vm.displayTime ->> timestampLabel.bnd_text
        vm.tagline ->> taglineLabel.bnd_text
        vm.busy ->> spinner.bnd_animating
        vm.hidePlayIcon ->> playIcon.bnd_hidden
        profileIconsView.bindTo(vm.profileIcons, cell: ProfileIconCell.self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // MAJOR TODO: Figure out how to unbind....
//        [nameLabel, timestampLabel, taglineLabel].each {
//            $0.designatedBond.unbindAll()
//        }
//        avatarView.imageBond.unbindAll()
//        playIcon.dynHidden.designatedBond.unbindAll()
//        profileIconsView.designatedBond.unbindAll()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.masksToBounds = true
    }
    
    static func reuseId() -> String {
        return "NewConnectionCell" // TODO: Remove me
    }
}