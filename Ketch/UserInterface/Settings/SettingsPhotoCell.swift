//
//  SettingsPhotoCell.swift
//  Ketch
//
//  Created by Tony Xiao on 4/16/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import XLForm

class SettingsPhotoCell : XLFormBaseCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarView: UserAvatarView!
    
    
    override class func formDescriptorCellHeightForRowDescriptor(rowDescriptor: XLFormRowDescriptor!) -> CGFloat {
        return 240
    }
}
