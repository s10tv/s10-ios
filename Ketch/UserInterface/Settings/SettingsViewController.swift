//
//  SettingsViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit

@objc(SettingsViewController)
class SettingsViewController : BaseViewController {

    @IBOutlet weak var avatarView: UserAvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Refactor me into utils
        let info = NSBundle.mainBundle().infoDictionary
        let build = info?["CFBundleVersion"] as String
        let version = info?["CFBundleShortVersionString"] as String
        versionLabel.text = "v\(version)(\(build))"

        let currentUser = User.currentUser()
        nameLabel.text = currentUser?.firstName
        avatarView.user = currentUser
        avatarView.whenTapped { [weak self] in
            self?.performSegueWithIdentifier("SettingsToProfile", sender: nil)
            return
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let profileVC = segue.destinationViewController as? ProfileViewController {
            profileVC.user = User.currentUser()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func goBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}
