//
//  MeServiceCell.swift
//  S10
//
//  Created by Tony Xiao on 6/30/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Core
import Bond

class MeServiceCell : UICollectionViewCell {

    @IBOutlet weak var serviceIconView: UIImageView!
    @IBOutlet weak var userDisplayNameLabel: UILabel!
    
    func bindViewModel(viewModel: ServiceViewModel) {
        viewModel.serviceIconURL ->> serviceIconView.dynImageURL
        viewModel.userDisplayName ->> userDisplayNameLabel
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        serviceIconView.unbindDynImageURL()
        userDisplayNameLabel.designatedBond.unbindAll()
    }
}