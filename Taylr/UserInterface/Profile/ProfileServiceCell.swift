//
//  ProfileServiceCell.swift
//  S10
//
//  Created by Tony Xiao on 6/30/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import Core
import Bond

class ProfileServiceCell : UITableViewCell {
    
    @IBOutlet weak var serviceIconView: UIImageView!
    @IBOutlet weak var userDisplayNameLabel: UILabel!

    var service: ServiceViewModel? {
        didSet { if let s = service { bindService(s) } }
    }
    
    func bindService(service: ServiceViewModel) {
        service.serviceIcon ->> serviceIconView
        service.userDisplayName ->> userDisplayNameLabel
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        serviceIconView.designatedBond.unbindAll()
        userDisplayNameLabel.designatedBond.unbindAll()
    }
    
}