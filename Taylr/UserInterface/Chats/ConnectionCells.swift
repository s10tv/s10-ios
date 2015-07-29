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
import Core

class ContactConnectionCell : UITableViewCell, BindableCell {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    func bind(vm: ContactConnectionViewModel) {
        vm.avatar ->> avatarView.imageBond
        vm.displayName ->> nameLabel
        vm.busy ->> spinner
        vm.statusMessage ->> subtitleLabel
        vm.badgeText ->> badgeLabel
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.unbindDynImageURL()
        [nameLabel, subtitleLabel, badgeLabel].each {
            $0.designatedBond.unbindAll()
        }
        badgeLabel.dynHidden.designatedBond.unbindAll()
        spinner.designatedBond.unbindAll()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.makeCircular()
    }
    
    static func reuseId() -> String {
        return reuseId(.ContactConnectionCell)
    }
}

class NewConnectionCell : UITableViewCell, BindableCell {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var playIcon: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var profileIconsView: UICollectionView!
 
    func bind(vm: NewConnectionViewModel) {
        vm.avatar ->> avatarView.imageBond
        vm.displayName ->> nameLabel
        vm.displayTime ->> timestampLabel
        vm.jobTitle ->> titleLabel
        vm.employer ->> subtitleLabel
        vm.profileIcons.map(profileIconsView.factory(ProfileIconCell)) ->> profileIconsView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.masksToBounds = true
    }
    
    static func reuseId() -> String {
        return reuseId(.NewConnectionCell)
    }
}