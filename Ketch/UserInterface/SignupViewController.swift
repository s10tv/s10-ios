//
//  SignupViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation

class SignupViewController : BaseViewController {
    
    // MARK: Actions
    @IBAction func didTapOnNotPicky(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL("http://tinder.com/"))
    }
    
    @IBAction func viewTerms(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(Env.termsAndConditionURL)
    }
    
    @IBAction func viewPrivacy(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(Env.privacyURL)
    }
    
    @IBAction func loginWithFacebook(sender: AnyObject) {
        Facebook.loginWithUI().subscribeError({ _ in
            self.performSegue(.SignupToFacebookPerm)
        }, completed: {
            self.performSegue(.SignupToNotificationsPerm)
        })
    }
}