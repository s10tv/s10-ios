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

class ConnectionCell : UITableViewCell {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet var nameCenterConstraint: NSLayoutConstraint! // TODO: Why is strong needed?
    
    func bindViewModel(vm: ContactConnectionViewModel) {
        vm.avatar ->> avatarView.imageBond
        vm.displayName ->> nameLabel
        vm.busy ->> spinner
        vm.statusMessage ->> subtitleLabel
        vm.badgeText ->> badgeLabel
        (vm.statusMessage |> map { $0.length == 0 }) ->> nameCenterConstraint.dynActive
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.unbindDynImageURL()
        [nameLabel, subtitleLabel, badgeLabel].each {
            $0.designatedBond.unbindAll()
        }
        badgeLabel.dynHidden.designatedBond.unbindAll()
        nameCenterConstraint.dynActive.designatedBond.unbindAll()
        spinner.designatedBond.unbindAll()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.makeCircular()
    }
}