//
//  WelcomeViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 2/26/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit

@objc(WelcomeViewController)
class WelcomeViewController : BaseViewController {
    
    var screens : [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        screens = map([1,2,3,4], { (number) -> UIViewController in
//            return self.storyboard?.instantiateViewControllerWithIdentifier("Page\(number)") as UIViewController
//        })
    }
}
