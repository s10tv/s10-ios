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
//        let data = FBSession.activeSession().accessTokenData
//        println("access token \(data.accessToken) expire \(data.expirationDate) userid \(data.userID) appid \(data.appID)")
//        println("login fetched user info \(user)")
        let root = self.navigationController as RootViewController
        root.showProfile(nil, animated: true)
    }
    
    func loginView(loginView: FBLoginView!, handleError error: NSError!) {
        println("login errored \(error)")
    }
}