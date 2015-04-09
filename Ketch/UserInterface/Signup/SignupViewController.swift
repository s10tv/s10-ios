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
    
    // MARK: Actions
    
    @IBAction func viewTerms(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(Env.termsAndConditionURL)
    }
    
    @IBAction func viewPrivacy(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(Env.privacyURL)
    }
    
    @IBAction func loginWithFacebook(sender: AnyObject) {
        Core.loginWithUI().subscribeCompleted {
            self.performSegue(.SignupToNotificationsPerm)
        }
    }
}