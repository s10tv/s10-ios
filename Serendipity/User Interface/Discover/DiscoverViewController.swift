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
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    
    var profileVC : ProfileViewController!
    var currentMatch : Match? {
        didSet {
            profileVC.user = currentMatch?.user
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for btn in [nextButton, messageButton] {
            btn.layer.cornerRadius = 5
            btn.layer.masksToBounds = true
        }

        profileVC = storyboard?.instantiateViewControllerWithIdentifier("Profile") as ProfileViewController
        addChildViewController(profileVC)
        view.insertSubview(profileVC.view, atIndex: 0)
        profileVC.view.makeEdgesEqualTo(view)
        
        // TODO: Figure out better way to do this that can be statically checked
        RAC(self, "currentMatch") <~ Core.matchService.currentMatch
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let chatVC = segue.destinationViewController as? ChatViewController {
            chatVC.user = currentMatch?.user
        }
    }
    
    // MARK: - Actions
    
    @IBAction func nextMatch(sender: AnyObject?) {
        if let match = currentMatch {
            Core.matchService.passMatch(match)
        }
    }
    
    @IBAction func messageMatch(sender: AnyObject?) {
        if let match = currentMatch {
            performSegueWithIdentifier("DiscoverToChat", sender: nil)
        }
    }
    
}
