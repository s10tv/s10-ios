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
    
    let bridge: RCTBridge
    
    init(bridge: RCTBridge) {
        self.bridge = bridge
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = RCTRootView(bridge: bridge, moduleName: "Taylr", initialProperties: nil)
    }
}