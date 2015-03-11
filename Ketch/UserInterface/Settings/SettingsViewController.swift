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
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var workLabel: UILabel!
    @IBOutlet weak var educationLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var aboutLabel: DesignableLabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = User.currentUser() {
            avatarView.user = user
            avatarView.whenTapped { [weak self] in
                self?.performSegue(.SettingsToProfile)
                return
            }
            nameLabel.text = user.firstName
            ageLabel.text = "\(user.age!) years old"
            workLabel.text = "You work at \(user.work!)"
            educationLabel.text = "Studied at \(user.education!)"
            heightLabel.text = "You are about \(user.height!)cm tall"
            aboutLabel.setRawText(user.about!)
        }
        
        // TODO: Refactor me into utils
        let info = NSBundle.mainBundle().infoDictionary
        let build = info?["CFBundleVersion"] as String
        let version = info?["CFBundleShortVersionString"] as String
        versionLabel.text = "v\(version)(\(build))"
    }
    
    @IBAction func giveFeedback(sender: AnyObject) {
        
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
