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
    @IBOutlet weak var deactivateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        avatarView.makeCircular()
        if let user = User.currentUser() {
            avatarView.user = user
            avatarView.whenTapped { [weak self, weak user] in
                let profileVC = ProfileViewController()
                profileVC.user = user
                self?.presentViewController(profileVC, animated: true)
            }
            nameLabel.text = user.displayName
            ageLabel.text = "\(user.age!) years old"
            workLabel.text = "You work at \(user.work!)"
            educationLabel.text = "Studied at \(user.education!)"
            heightLabel.text = "You are about \(user.height!)cm tall"
            aboutLabel.rawText = user.about!
        }
    }
    
    @IBAction func giveFeedback(sender: AnyObject) {
        
    }
    
    @IBAction func deactivateUser(sender: AnyObject) {
        if let currentUser = User.currentUser() {
            Core.meteor.callMethod("user/delete", params: [currentUser.documentID!])
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let profileVC = segue.destinationViewController as? ProfileViewController {
            profileVC.user = User.currentUser()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func goBack(sender: AnyObject) {
        dismissViewControllerAnimated(true)
    }
}
