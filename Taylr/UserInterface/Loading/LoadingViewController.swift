//
//  LoadingViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/3/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Core

class LoadingViewController : UIViewController {
    
    private var lastUnwindSegue: UIStoryboardSegue?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if Meteor.account == nil {
            performSegue(.Onboarding_Signup, sender: self)
        } else {
            performSegue(.LoadingToDiscover, sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segue = segue as? AdvancedPushSegue {
            segue.animated = false
            segue.replaceStrategy = .Stack
        }
    }
    
    @IBAction func unwindToLoading(sender: UIStoryboardSegue) {
        lastUnwindSegue = sender
    }
}