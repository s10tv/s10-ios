//
//  DiscoverViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import Snap
import SugarRecord

@objc(DiscoverViewController)
class DiscoverViewController : BaseViewController {
    
//    var matches : [User] = []
    var matches : SugarRecordResults!
    var profileVC : ProfileViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileVC = storyboard?.instantiateViewControllerWithIdentifier("Profile") as ProfileViewController
        addChildViewController(profileVC)
        view.insertSubview(profileVC.view, atIndex: 0)
        profileVC.view.snp_makeConstraints { make in
            make.edges.equalTo(self.view)
            return
        }
        Core.prepareMatches()
        matches = User.all().find()
        nextMatch(nil)
    }
    
    @IBAction func nextMatch(sender: AnyObject?) {
        if let match = matches.firstObject() as? User {
            profileVC.user = match
        }
    }
    
    @IBAction func messageMatch(sender: AnyObject?) {
        
    }
    
    
    @IBAction func showSettings(sender: AnyObject) {
        performSegueWithIdentifier("DiscoverToSettings", sender: sender)
    }
    
    @IBAction func showConnections(sender: AnyObject) {
        performSegueWithIdentifier("DiscoverToConnections", sender: sender)
    }
}
