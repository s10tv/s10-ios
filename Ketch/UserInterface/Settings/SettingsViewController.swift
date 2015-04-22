//
//  SettingsViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import Cartography
import ReactiveCocoa

class SettingsViewController : BaseViewController {
    
    @IBOutlet weak var waveView: WaveView!
    var formController: SettingsFormViewController!
    
    override func commonInit() {
        screenName = "Settings"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        formController = makeViewController(.SettingsForm) as SettingsFormViewController
        addChildViewController(formController)
        view.insertSubview(formController.view, atIndex: 0)
        constrain(formController.view, view, waveView) { tableView, view, waveView in
            tableView.top == view.top
            tableView.leading == view.leading
            tableView.trailing == view.trailing
            tableView.bottom == waveView.top
        }
        formController.didMoveToParentViewController(self)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == SegueIdentifier.Main_Chat.rawValue {
            if Connection.crabConnection() == nil {
                showAlert(LS(.ketchyUnavailableTitle), message: LS(.ketchyUnavailableMessage))
                return false
            }
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
    
    // MARK: - Action

    @IBAction func showLogoutOptions(sender: AnyObject) {
        let sheet = UIAlertController(title: LS(.settingsLogoutTitle), message: nil, preferredStyle: .ActionSheet)
        sheet.addAction(LS(.settingsLogoutLogout)) { _ in
            Globals.accountService.logout()
            self.performSegue(.SettingsToLoading)
        }
        sheet.addAction(LS(.settingsLogoutDeleteAccount), style: .Destructive) { _ in
            self.showDeleteAccountAlert(sender)
        }
        sheet.addAction(LS(.settingsLogoutCancel), style: .Cancel)
        presentViewController(sheet)
    }
    
    @IBAction func showDeleteAccountAlert(sender: AnyObject) {
        var alert = UIAlertController(title: LS(.settingsDeleteAccountTitle), message:LS(.settingsDeleteAccountMessage), preferredStyle: .Alert)
        // NOTE: Not using .Destructive style here becauase it does not change color when disabled
        let confirmAction = alert.addAction(LS(.settingsDeleteAccountConfirm)) { _ in
            Globals.accountService.deleteAccount()
            self.performSegue(.SettingsToLoading)
        }
        alert.addAction(LS(.settingsDeleteAccountCancel), style: .Cancel)
        alert.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = LS(.settingsDeleteAccountPlaceholder)
            textField.rac_textSignal().subscribeNextAs { (text: String) in
                confirmAction.enabled = (text == "delete")
            }
        }
        presentViewController(alert)
    }
}
