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
    
    @IBAction func viewTerms(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://ketchtheone.com/terms.html")!)
    }
    
    @IBAction func viewPrivacy(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://ketchtheone.com/privacy.html")!)
    }
    
}