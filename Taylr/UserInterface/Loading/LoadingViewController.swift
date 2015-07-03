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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if Globals.accountService.status == .NotLoggedIn {
            self.performSegueWithStatus(Globals.accountService.status)
        } else {
            // Wait until user data is there so we know whether user has signed up before showing discover
            Meteor.subscriptions.userData.whenDone { _ in
                self.performSegueWithStatus(Globals.accountService.status)
            }
        }
    }
    
    func performSegueWithStatus(status: AccountService.Status) {
        switch status {
        case .NotLoggedIn:
            performSegue(.Onboarding_Login, sender: self)
        case .Pending:
            performSegue(.Onboarding_Login, sender: self) // Should be Onbaording_Signup
        case .SignedUp:
            performSegue(.LoadingToDiscover, sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segue = segue as? AdvancedPushSegue {
            segue.animated = false
            segue.replaceStrategy = .Stack
        }
    }
    
}