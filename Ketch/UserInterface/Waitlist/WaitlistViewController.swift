//
//  WaitlistViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 4/3/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

@objc(WaitlistViewController)
class WaitlistViewController : BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKetchBoat = false
        waterlineLocation = .Ratio(0.55)
    }
}
