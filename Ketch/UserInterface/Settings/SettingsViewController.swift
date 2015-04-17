//
//  SettingsViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit

class SettingsViewController : BaseViewController {
    
    var formController: SettingsFormViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        formController = makeViewController(.SettingsForm) as SettingsFormViewController
        addChildViewController(formController)
        view.insertSubview(formController.view, atIndex: 0)
        formController.view.makeEdgesEqualTo(view)
        formController.didMoveToParentViewController(self)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == SegueIdentifier.Main_Chat.rawValue {
            return Connection.crabConnection() != nil
        }
        return super.shouldPerformSegueWithIdentifier(identifier, sender: sender)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let chatVC = segue.destinationViewController as? ChatViewController {
            chatVC.connection = Connection.crabConnection()
        } else if let profileVC = segue.destinationViewController as? ProfileViewController {
            profileVC.user = User.currentUser()
        }
    }

    // MARK: -
    
    // every time text is changed, check to see if it is 'delete'
    func textChanged(sender:AnyObject) {
        let tf = sender as UITextField
        var resp : UIResponder = tf
        while !(resp is UIAlertController) { resp = resp.nextResponder()! }
        let alert = resp as UIAlertController
        (alert.actions[1] as UIAlertAction).enabled = (tf.text == "delete")
    }
    
    @IBAction func deactivateUser(sender: AnyObject) {
        var alert = UIAlertController(title: "Delete Account", message:
            "All your photos, messages, and matches will be permanently deleted.\nPlease type 'delete' to confirm.",
            preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler {
            (tf:UITextField!) in
            tf.placeholder = "Sure?"
            tf.addTarget(self, action: "textChanged:", forControlEvents: .EditingChanged)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default, handler: { action in
            if let currentUser = User.currentUser() {
                Meteor.deleteAccount()
            }
        }))
        
        // initially disable the "confirm" action
        (alert.actions[1] as UIAlertAction).enabled = false
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
