//
//  SettingsTextCell.swift
//  Ketch
//
//  Created by Tony Xiao on 4/16/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import XLForm

class SettingsTextCell : XLFormBaseCell {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    override class func formDescriptorCellHeightForRowDescriptor(rowDescriptor: XLFormRowDescriptor!) -> CGFloat {
        return 60
    }
    
}