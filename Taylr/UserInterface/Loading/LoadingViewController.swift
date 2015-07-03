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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if Globals.accountService.status == .NotLoggedIn {
            self.performSegueWithStatus(Globals.accountService.status)
        } else {
            // Wait until user data is there so we know whether user has signed up before showing discover
            Meteor.subscriptions.userData.signal.delay(0.1).deliverOnMainThread().subscribeCompleted {
                self.performSegueWithStatus(Globals.accountService.status)
            }
        }
    }
    
    func performSegueWithStatus(status: AccountService.Status) {
        switch status {
        case .NotLoggedIn:
            performSegue(.Onboarding_Login, sender: self)
        case .Pending:
            performSegue(.Onboarding_Signup, sender: self)
        case .SignedUp:
            performSegue(.LoadingToDiscover, sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segue = segue as? AdvancedPushSegue {
            segue.animated = false
            segue.replaceStrategy = .Stack
            if let vc = segue.destinationViewController as? SignupViewController {
                vc.viewModel = SignupViewModel(user: Meteor.user!)
                // TODO: Move this type of stuff into the router
                let onboarding = UIStoryboard(name: "Onboarding", bundle: nil)
                let login = onboarding.instantiateInitialViewController() as! UIViewController
                segue.replaceStrategy = .BackStack([login])
            }
        }
    }
    
}