//
//  ConnectionCell.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/4/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import SDWebImage
import DateTools
import Core
import Bond

class ConnectionCell : UITableViewCell {
    
    @IBOutlet weak var avatarView: UserAvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet var nameCenterConstraint: NSLayoutConstraint! // TODO: Why is strong needed?
    
    var viewModel : ConversationViewModel? {
        didSet { if let vm = viewModel { bindViewModel(vm) } }
    }
    
    func bindViewModel(viewModel: ConversationViewModel) {
        avatarView.user = viewModel.recipient.value
        viewModel.recipient.value?.displayName ?? Dynamic("") ->> nameLabel
        viewModel.hasUnsentMessage ->> spinner
        viewModel.formattedStatus ->> subtitleLabel
        viewModel.badgeText ->> badgeLabel
        viewModel.formattedStatus.map { $0.length == 0 } ->> nameCenterConstraint.dynActive
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.unbindDynImageURL()
        unbindAll(nameLabel, subtitleLabel, badgeLabel)
        badgeLabel.dynHidden.designatedBond.unbindAll()
        nameCenterConstraint.dynActive.designatedBond.unbindAll()
        spinner.designatedBond.unbindAll()
    }
}