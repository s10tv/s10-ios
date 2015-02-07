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
        avatarView.makeCircular()

        // TODO: Refactor me into utils
        let info = NSBundle.mainBundle().infoDictionary
        let version = info?["CFBundleVersion"] as String
        let build = info?["CFBundleShortVersionString"] as String
        versionLabel.text = "v\(version)(\(build))"

        let currentUser = User.currentUser()
        avatarView.sd_setImageWithURL(currentUser.profilePhotoURL)
        nameLabel.text = currentUser.firstName
    }
    
    // MARK: - Actions
    
    @IBAction func viewProfile(sender: AnyObject) {
        
    }
    
    @IBAction func inviteFriends(sender: AnyObject) {
    }
    
    
    @IBAction func sendFeedback(sender: AnyObject) {
        
    }
    
    @IBAction func logout(sender: AnyObject) {
        
    }
}
