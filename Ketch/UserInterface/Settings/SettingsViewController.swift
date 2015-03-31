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
    
    var deactivateAccountConfirmationTextField: UITextField?
    
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

    // every time text is changed, check to see if it is 'delete'
    func textChanged(sender:AnyObject) {
        let tf = sender as UITextField
        var resp : UIResponder = tf
        while !(resp is UIAlertController) { resp = resp.nextResponder()! }
        let alert = resp as UIAlertController
        (alert.actions[1] as UIAlertAction).enabled = (tf.text == "delete")
    }
    
    @IBAction func deactivateUser(sender: AnyObject) {
        var alert = UIAlertController(title: "Delete Account", message: "This action cannot be undone. \nType 'delete' to confirm", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler {
            (tf:UITextField!) in
            tf.placeholder = "Sure?"
            tf.addTarget(self, action: "textChanged:", forControlEvents: .EditingChanged)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default, handler: { action in
            if let currentUser = User.currentUser() {
                Core.meteor.callMethod("user/delete", params: [currentUser.documentID!])
            }
        }))
        
        // initially disable the "confirm" action
        (alert.actions[1] as UIAlertAction).enabled = false
        self.presentViewController(alert, animated: true, completion: nil)
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
