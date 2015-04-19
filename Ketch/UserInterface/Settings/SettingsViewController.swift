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
    
    // MARK: - Action

    @IBAction func showLogoutOptions(sender: AnyObject) {
        let sheet = UIAlertController(title: LS(R.Strings.settingsLogoutTitle), message: nil, preferredStyle: .ActionSheet)
        sheet.addAction(LS(R.Strings.settingsLogoutLogout)) { _ in
            Account.logout()
            self.performSegue(.SettingsToLoading)
        }
        sheet.addAction(LS(R.Strings.settingsLogoutDeleteAccount), style: .Destructive) { _ in
            self.showDeleteAccountAlert(sender)
        }
        sheet.addAction(LS(R.Strings.settingsLogoutCancel), style: .Cancel)
        presentViewController(sheet)
    }
    
    @IBAction func showDeleteAccountAlert(sender: AnyObject) {
        var alert = UIAlertController(title: LS(R.Strings.settingsDeleteAccountTitle), message:LS(R.Strings.settingsDeleteAccountMessage), preferredStyle: .Alert)
        // NOTE: Not using .Destructive style here becauase it does not change color when disabled
        let confirmAction = alert.addAction(LS(R.Strings.settingsDeleteAccountConfirm)) { _ in
            Account.deleteAccount()
            self.performSegue(.SettingsToLoading)
        }
        alert.addAction(LS(R.Strings.settingsDeleteAccountCancel), style: .Cancel)
        alert.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = LS(R.Strings.settingsDeleteAccountPlaceholder)
            textField.rac_textSignal().subscribeNextAs { (text: String) in
                confirmAction.enabled = (text == "delete")
            }
        }
        presentViewController(alert)
    }
}
