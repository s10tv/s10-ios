//
//  MeViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/22/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import MessageUI
import Core

class MeViewController : UITableViewController {
    
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var inviteContainer: UIView!
    @IBOutlet weak var servicesCollectionView: UICollectionView!
    @IBOutlet weak var hashtagsView: UICollectionView!
    
    var vm: MeViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0.01))
        
        vm = MeViewModel(MainContext)
        avatarView.sd_image <~ vm.avatar
        coverView.sd_image <~ vm.cover
        nameLabel.rac_text <~ vm.displayName
        servicesCollectionView <~ (vm.profileIcons, ProfileIconCell.self)
        
        versionLabel.text = "Taylr v\(Globals.env.version) (\(Globals.env.build))"
        
        hashtagsView <~ (vm.hashtags, HashtagCell.self)
        // Observe collectionView height and reload table view cell height whenever appropriate
        hashtagsView.dyn("contentSize").force(NSValue).producer
            .skip(1)
            .skipRepeats()
            .observeOn(QueueScheduler.mainQueueScheduler)
            .startWithNext { _ in
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        
        listenForNotification(DidTouchStatusBar).startWithNext { [weak self] _ in
            self?.tableView.scrollToTop(animated: true)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.track("View: Me")
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

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset = UIEdgeInsets(top: topLayoutGuide.length, left: 0,
            bottom: bottomLayoutGuide.length, right: 0)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == SegueIdentifier.MeToEditProfile.rawValue
            || identifier == SegueIdentifier.MeToProfile.rawValue
            || identifier == SegueIdentifier.MeToProfile2.rawValue {
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
    }
    
    // MARK: -
    
    @IBAction func didPressContactSupport(sender: AnyObject) {
        Globals.analyticsService.track("Me: ContactUs")
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.setToRecipients(["hello@taylrapp.com"])
            mail.setSubject("Taylr Feedback")
            mail.mailComposeDelegate = self
            presentViewController(mail, animated: true)
        } else {
            showAlert("Cannot contact support", message: "No email account available.")
        }
    }
    
    @IBAction func didPressMore(sender: AnyObject) {
        let sheet = UIAlertController(title: LS(.settingsMoreTitle), message: nil, preferredStyle: .ActionSheet)
        sheet.addAction(LS(.settingsFeedbackTitle)) { _ in
            self.didPressContactSupport(sender)
        }
        sheet.addAction(LS(.settingsLogoutTitle), style: .Destructive) { _ in
            Globals.accountService.logout()
            self.performSegue(.Onboarding_Login)
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

// HACK ALERT: Better way than hardcode?
private let HashtagsIndexPath = NSIndexPath(forRow: 0, inSection: 3)

extension MeViewController /*: UITableViewDelegate */{
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == HashtagsIndexPath.section { // hashtags section
            return hashtagsView.collectionViewLayout.collectionViewContentSize().height + 16 * 2
        }
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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

// Hastags Size Calculation
private let HashtagFont = UIFont(.cabinRegular, size: 14)

extension MeViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let hashtag = vm.hashtags.array[indexPath.item]
        var size = (hashtag.displayText as NSString).boundingRectWithSize(CGSizeMake(1000, 1000),
            options: [], attributes: [NSFontAttributeName: HashtagFont], context: nil).size
        size.width += 10 * 2
        size.height += 8 * 2
        return size
    }
}