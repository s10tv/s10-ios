//
//  Appearance.swift
//  S10
//
//  Created by Tony Xiao on 7/31/15.
//  Copyright (c) 2015 S10. All rights reserved.
//


import UIKit

struct Appearance {
    
    static func setupGlobalAppearances() {
        UINavigationBar.appearance().barTintColor = StyleKit.brandPurple
        UINavigationBar.appearance().tintColor = StyleKit.textWhite
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont(.cabinMedium, size: 20),
            NSForegroundColorAttributeName: StyleKit.textWhite
        ]
        
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName : UIFont(.cabinRegular, size: 16)
        ], forState: .Normal)
        
        UISegmentedControl.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont(.cabinRegular, size: 14)
        ], forState: .Normal)
    }
}