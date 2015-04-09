//
//  WelcomeViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 4/9/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class WelcomeViewController : CloudsViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.matches(.FinishWelcome) {
            // TODO: Set welcomed = true
        }
    }
}