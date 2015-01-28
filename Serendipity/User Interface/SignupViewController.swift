//
//  SignupViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation

@objc(SignupViewController)
class SignupViewController : BaseViewController, FBLoginViewDelegate {
    
    @IBOutlet weak var fbLoginView: FBLoginView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fbLoginView.delegate = self
        
    }
    
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
        println("login fetched user info \(user)")
    }
    
    func loginView(loginView: FBLoginView!, handleError error: NSError!) {
        println("login errored \(error)")
    }
    
}