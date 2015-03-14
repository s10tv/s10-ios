//
//  SignupViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation

@objc(SignupViewController)
class SignupViewController : BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // TODO: Different behavior based on whether it's an existing or new user
    @IBAction func login(sender: AnyObject) {
        Core.loginWithUI().subscribeCompleted {
//            let root = self.navigationController as RootViewController
//            root.showGame(true)
        }
    }

}