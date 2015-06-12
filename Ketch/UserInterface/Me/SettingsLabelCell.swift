//
//  SettingsLabelCell.swift
//  Ketch
//
//  Created by Tony Xiao on 4/17/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit
import XLForm

class SettingsLabelCell : XLFormBaseCell {
    @IBOutlet weak var label: UILabel!
    
    override func update() {
        super.update()
        label.text = rowDescriptor.value as? String
    }
}