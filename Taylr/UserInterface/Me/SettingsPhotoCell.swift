//
//  SettingsPhotoCell.swift
//  Taylr
//
//  Created by Tony Xiao on 4/16/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import XLForm

class SettingsPhotoCell : XLFormBaseCell {
    
    @IBOutlet weak var avatarView: UserAvatarView!
    
    override func update() {
        super.update()
        avatarView.sd_setImageWithURL(rowDescriptor.value as? NSURL)
    }

}
