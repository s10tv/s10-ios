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
    
    var matches : [User] = []
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
        
        nextMatch(nil)
    }
    
    @IBAction func nextMatch(sender: AnyObject?) {
        // TODO: Prevent this method from called multiple times in a row
        MatchService.getNextMatch().subscribeNextAs { (match: User) -> () in
            self.profileVC.user = match
        }
    }
    
    @IBAction func messageMatch(sender: AnyObject?) {
        if let match = MatchService.currentMatch {
            match.likeUser() // Message User
            // Go to connections / recorder view
        }
    }
    
    
    @IBAction func showSettings(sender: AnyObject) {
        performSegueWithIdentifier("DiscoverToSettings", sender: sender)
    }
    
    @IBAction func showConnections(sender: AnyObject) {
        performSegueWithIdentifier("DiscoverToConnections", sender: sender)
//         Temporary workaround to get to video recorder screen:
//        let vc = storyboard?.instantiateViewControllerWithIdentifier("VideoRecorder") as UIViewController!
//        navigationController?.pushViewController(vc, animated: true)
    }
}
