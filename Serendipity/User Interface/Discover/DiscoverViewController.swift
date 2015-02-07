//
//  DiscoverViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import Snap

@objc(DiscoverViewController)
class DiscoverViewController : BaseViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    
    var matches : [User] = []
    var profileVC : ProfileViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for btn in [nextButton, messageButton] {
            btn.layer.cornerRadius = 5
            btn.layer.masksToBounds = true
        }

        profileVC = storyboard?.instantiateViewControllerWithIdentifier("Profile") as ProfileViewController
        addChildViewController(profileVC)
        view.insertSubview(profileVC.view, atIndex: 0)
        profileVC.view.snp_makeConstraints { make in
            make.edges.equalTo(self.view)
            return
        }
        
        nextMatch(nil)
    }
    
    @IBAction func nextMatch(sender: AnyObject?) {
        // TODO: Prevent this method from called multiple times in a row
        MatchService.getNextMatch().subscribeNextAs { (match: Match) -> () in
            self.profileVC.user = match.user
        }
    }
    
    @IBAction func messageMatch(sender: AnyObject?) {
        if let match = MatchService.currentMatch {
            match.user?.makeConnection() // Message User
            showConnections(nil)
        }
    }
    
    
    @IBAction func showSettings(sender: AnyObject?) {
        performSegueWithIdentifier("DiscoverToSettings", sender: sender)
    }
    
    @IBAction func showConnections(sender: AnyObject?) {
        performSegueWithIdentifier("DiscoverToConnections", sender: sender)
    }
}
