//
//  Appearance.swift
//  S10
//
//  Created by Tony Xiao on 7/31/15.
//  Copyright (c) 2015 S10. All rights reserved.
//


import UIKit
import AMPopTip

struct Appearance {
    
    static func setupGlobalAppearances() {
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName : UIFont(.cabinRegular, size: 16)
        ], forState: .Normal)
        
        UISegmentedControl.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont(.cabinRegular, size: 14)
        ], forState: .Normal)
        
        AMPopTip.appearance().font = UIFont(.cabinRegular, size: 14)
        AMPopTip.appearance().popoverColor = UIColor(white: 0, alpha: 0.4)
    }
}