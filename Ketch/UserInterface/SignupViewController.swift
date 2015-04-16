//
//  SignupViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import PKHUD

class SignupViewController : BaseViewController {

    override func commonInit() {
        allowedStates = [.Signup]
    }
    
    // MARK: Actions
    @IBAction func didTapOnNotPicky(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(Env.notPickyExitURL)
    }
    
    @IBAction func viewTerms(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(Env.termsAndConditionURL)
    }
    
    @IBAction func viewPrivacy(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(Env.privacyURL)
    }
    
    @IBAction func loginWithFacebook(sender: AnyObject) {
        // Temp hack, timing issue
        allowedStates = [.Signup, .Waitlist, .Welcome]
        PKHUD.showActivity()
        Account.login().subscribeError({ _ in
            PKHUD.hide()
            self.performSegue(.SignupToFacebookPerm)
        }, completed: {
            PKHUD.hide()
            self.performSegue(.SignupToNotificationsPerm)
        })
    }
}