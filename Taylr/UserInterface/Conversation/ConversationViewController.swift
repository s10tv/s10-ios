//
//  ConversationViewController.swift
//  S10
//
//  Created by Tony Xiao on 10/14/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Atlas
import Core

class ConversationViewController : ATLConversationViewController {

    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    var vm: ConversationViewModel! {
        didSet { conversation = vm.conversation }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = vm
        
        let backgroundImageView = UIImageView()
        backgroundImageView.contentMode = .ScaleAspectFill
        backgroundImageView.clipsToBounds = true
        view.insertSubview(backgroundImageView, atIndex: 0)
        backgroundImageView.makeEdgesEqualTo(view)

        let backgroundMask = UIView()
        backgroundMask.backgroundColor = UIColor(white: 0, alpha: 0.2)
        view.insertSubview(backgroundMask, aboveSubview: backgroundImageView)
        backgroundMask.makeEdgesEqualTo(backgroundImageView)
        
        avatarView.sd_image <~ vm.avatar
        titleLabel.rac_text <~ vm.displayName
        statusLabel.rac_text <~ vm.displayStatus
        backgroundImageView.sd_image <~ vm.cover
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ProfileViewController {
            vc.vm = vm.profileVM()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func didTapBackButton(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func showMoreOptions(sender: AnyObject) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        sheet.addAction(LS(.viewProfile)) { _ in
            self.performSegue(.ConversationToProfile)
        }
        sheet.addAction(LS(.moreSheetBlock, vm.displayName.value), style: .Destructive) { _ in
            self.blockUser(self)
        }
        sheet.addAction(LS(.moreSheetReport, vm.displayName.value), style: .Destructive) { _ in
            self.reportUser(self)
        }
        sheet.addAction(LS(.moreSheetCancel), style: .Cancel)
        presentViewController(sheet)
    }
    
    // TODO: FIX CODE DUPLICATION WITH ProfileViewController
    @IBAction func blockUser(sender: AnyObject) {
        let alert = UIAlertController(title: "Block User",
            message: "Are you sure you want to block \(vm.displayName.value)?",
            preferredStyle: .Alert)
        alert.addAction("Cancel", style: .Cancel)
        alert.addAction("Block", style: .Destructive) { _ in
            self.vm.blockUser()
            Analytics.track("User: Block")
            let dialog = UIAlertController(title: "Block User", message: "\(self.vm.displayName.value) will no longer be able to contact you in the future", preferredStyle: .Alert)
            dialog.addAction("Ok", style: .Default)
            self.presentViewController(dialog)
            
        }
        presentViewController(alert)
    }
    
    @IBAction func reportUser(sender: AnyObject) {
        let alert = UIAlertController(title: LS(.reportAlertTitle), message: LS(.reportAlertMessage), preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler(nil)
        alert.addAction(LS(.reportAlertCancel), style: .Cancel)
        alert.addAction(LS(.reportAlertConfirm), style: .Destructive) { _ in
            if let reportReason = alert.textFields?[0].text {
                Analytics.track("User: Report", ["Reason": reportReason])
                self.vm.reportUser(reportReason)
            }
        }
        presentViewController(alert)
    }
}

// MARK: - ATLConversationViewControllerDataSource

extension ConversationViewModel : ATLConversationViewControllerDataSource {
    
    public func conversationViewController(conversationViewController: ATLConversationViewController!, participantForIdentifier participantIdentifier: String!) -> ATLParticipant! {
        return recipient()
    }
    
    public func conversationViewController(conversationViewController: ATLConversationViewController!, attributedStringForDisplayOfDate date: NSDate!) -> NSAttributedString! {
        return NSAttributedString(string: "Date")
    }
    
    public func conversationViewController(conversationViewController: ATLConversationViewController!, attributedStringForDisplayOfRecipientStatus recipientStatus: [NSObject : AnyObject]!) -> NSAttributedString! {
        return NSAttributedString(string: "Status")
    }
    
}

