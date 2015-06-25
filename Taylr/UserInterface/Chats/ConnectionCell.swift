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
    
    var viewModel : ConversationViewModel? {
        didSet { if let vm = viewModel { bindViewModel(vm) } }
    }
    
    func bindViewModel(viewModel: ConversationViewModel) {
        avatarView.user = viewModel.recipient.value
        viewModel.recipient.value!.displayName ->> nameLabel
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.sd_cancelCurrentImageLoad()
        nameLabel.designatedBond.unbindAll()
    }
}