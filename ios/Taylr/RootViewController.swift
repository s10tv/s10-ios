//
//  RootViewController.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import UIKit
import React

class RootViewController : UIViewController {
    
    private(set) var bridge: RCTBridge!
    
    convenience init(bridge: RCTBridge) {
        self.init(nibName: nil, bundle: nil)
        self.bridge = bridge
    }
    
    override func loadView() {
        view = RCTRootView(bridge: bridge, moduleName: "Taylr", initialProperties: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}