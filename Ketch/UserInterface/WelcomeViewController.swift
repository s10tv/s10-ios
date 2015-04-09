//
//  WelcomeViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 4/9/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class WelcomeViewController : CloudsViewController {
    
    @IBAction func finishWelcome(sender: AnyObject) {
        // TODO: Set approval state = true
        navigationController?.popToRootViewControllerAnimated(true)
    }
}