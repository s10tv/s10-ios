//
//  MeViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/22/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Bond
import MessageUI
import Core

class MeViewController : UITableViewController {
    
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var inviteContainer: UIView!
    @IBOutlet weak var servicesCollectionView: UICollectionView!
    
    var vm: MeViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0.01))
        
        vm = MeViewModel(meteor: Meteor, taskService: Globals.taskService)
        avatarView.rac_image <~ vm.avatar
        coverView.rac_image <~ vm.cover
        vm.displayName ->> nameLabel.bnd_text
        
        servicesCollectionView.bindTo(vm.profileIcons, cell: ProfileIconCell.self)
        
        versionLabel.text = "Taylr v\(Globals.env.version) (\(Globals.env.build))"
        
        listenForNotification(DidTouchStatusBar).startWithNext { [weak self] _ in
            self?.tableView.scrollToTop(animated: true)
        }
    }
    
    var hackedOffset = false
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
         // Totally stupid hack, donno why needed, probably related to nesting TabBarViewController inside nav controller
        if !hackedOffset {
            hackedOffset = true
            tableView.contentOffset = CGPoint(x: 0, y: -66)
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Globals.analyticsService.screen("Me")
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset = UIEdgeInsets(top: topLayoutGuide.length, left: 0,
            bottom: bottomLayoutGuide.length, right: 0)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == SegueIdentifier.MeToEditProfile.rawValue || identifier == SegueIdentifier.MeToProfile.rawValue {
            return vm.canViewOrEditProfile()
        }
        return super.shouldPerformSegueWithIdentifier(identifier, sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ProfileViewController {
            vc.vm = vm.profileVM()
        }
        if let vc = segue.destinationViewController as? EditProfileViewController {
            vc.vm = vm.editProfileVM()
        }
        if let segue = segue as? LinkedStoryboardPushSegue where segue.matches(.Onboarding_Login) {
            segue.replaceStrategy = .Stack
        }
    }
    
    // MARK: -
    
    @IBAction func didPressContactSupport(sender: AnyObject) {
        Globals.analyticsService.track("Contacted Support")
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.setToRecipients(["hello@s10.tv"])
            mail.setSubject("Taylr Feedback")
            mail.mailComposeDelegate = self
            presentViewController(mail, animated: true)
        } else {
            showAlert("Cannot contact support", message: "No email account available.")
        }
    }
    
    @IBAction func didPressLogout(sender: AnyObject) {
        Globals.analyticsService.track("Logged Out")
        let sheet = UIAlertController(title: LS(.settingsLogoutTitle), message: nil, preferredStyle: .ActionSheet)
        sheet.addAction(LS(.settingsLogoutLogout)) { _ in
            Globals.accountService.logout()
            self.performSegue(.Onboarding_Login, sender: self)
        }
        sheet.addAction(LS(.settingsLogoutCancel), style: .Cancel)
        presentViewController(sheet)
    }
}

extension MeViewController : MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewController(animated: true)
    }
}

// Hide the invites section

extension MeViewController /*: UITableViewDataSource */{
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 0
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
}

extension MeViewController /*: UITableViewDelegate */{
    override  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return nil
        }
        return super.tableView(tableView, titleForHeaderInSection: section)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 0.1
        }
        return super.tableView(tableView, heightForHeaderInSection: section)
    }
}