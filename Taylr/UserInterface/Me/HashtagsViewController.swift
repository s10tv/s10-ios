//
//  HashtagsViewController.swift
//  S10
//
//  Created by Tony Xiao on 11/3/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import React

class HashtagsViewController : UIViewController {
    override func loadView() {
        self.view = RCTRootView(bridge: Globals.reactBridge, moduleName: "TaylrReact", initialProperties: nil)
    }
}