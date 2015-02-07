//
//  SettingsViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit

@objc(SettingsViewController)
class SettingsViewController : UIViewController {

    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true

        // TODO: Refactor me into utils
        let info = NSBundle.mainBundle().infoDictionary
        let build = info?["CFBundleVersion"] as String
        let version = info?["CFBundleShortVersionString"] as String
        versionLabel.text = "v\(version)(\(build))"

        let currentUser = User.currentUser()
        avatarView.sd_setImageWithURL(currentUser.profilePhotoURL)
        nameLabel.text = currentUser.firstName
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarView.makeCircular()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let profileVC = segue.destinationViewController as? ProfileViewController {
            profileVC.user = User.currentUser()
        }
    }
    
    // MARK: - Actions
    @IBAction func backToDiscover(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(false)
    }
    
    @IBAction func viewProfile(sender: AnyObject) {
        self.performSegueWithIdentifier("SettingsToProfile", sender: sender)
    }
    
    @IBAction func inviteFriends(sender: AnyObject) {
    }
    
    
    @IBAction func sendFeedback(sender: AnyObject) {
        
    }
    
    @IBAction func logout(sender: AnyObject) {
        
    }
}
