//
//  IntegrationCell.swift
//  S10
//
//  Created by Tony Xiao on 7/24/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField
import Core

class IntegrationCell : UICollectionViewCell, BindableCell {
    typealias ViewModel = IntegrationViewModel
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleField: JVFloatLabeledTextField!
    @IBOutlet weak var statusView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    func bind(vm: IntegrationViewModel) {
        iconView.rac_image.value = vm.icon
        titleField.placeholder = vm.name
        titleField.text = vm.username
        statusView.rac_image.value = vm.statusImage
        vm.showSpinner ? spinner.startAnimating() : spinner.stopAnimating()
    }
    
    static func reuseId() -> String {
        return reuseId(.IntegrationCell)
    }
}