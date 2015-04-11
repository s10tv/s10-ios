//
//  PKHUDExtension.swift
//  Ketch
//
//  Created by Tony Xiao on 4/11/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import PKHUD

extension PKHUD {
    class func show(dimsBackground: Bool = false) {
        sharedHUD.dimsBackground = dimsBackground
        sharedHUD.show()
    }
    class func showActivity(dimsBackground: Bool = false) {
        sharedHUD.contentView = PKHUDSystemActivityIndicatorView()
        show(dimsBackground: dimsBackground)
    }
    class func hide(animated anim: Bool = true) {
        sharedHUD.hide(animated: anim)
    }
    class func hide(afterDelay delay: NSTimeInterval) {
        sharedHUD.hide(afterDelay: delay)
    }
}