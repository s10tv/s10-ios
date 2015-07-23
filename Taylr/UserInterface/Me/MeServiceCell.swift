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

class ServiceCell : UICollectionViewCell {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    func bindViewModel(viewModel: ServiceViewModel) {
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconView.unbindDynImageURL()
        statusImageView.unbindDynImageURL()
        titleLabel.designatedBond.unbindAll()
        spinner.designatedBond.unbindAll()
    }
}