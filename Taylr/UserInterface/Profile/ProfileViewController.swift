//
//  ProfileViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/27/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import SwipeView
import SDWebImage
import Cartography
import Bond
import Core

class ProfileViewController : BaseViewController {

    @IBOutlet weak var webView: UIWebView!
    var profileVM: ProfileInteractor!

    override func viewDidLoad() {
        var urlString = Globals.env.profileHostName
        if let username = profileVM.user.username {
            let url = NSURL(urlString + "/" + username)
            self.webView.loadRequest(NSURLRequest(URL: url))
        }

        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ConversationViewController {
            vc.conversationVM = ConversationInteractor(recipient: profileVM.user)
        }
    }
    
    // MARK: - Action
    
    @IBAction func showMoreOptions(sender: AnyObject) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        sheet.addAction(LS(.moreSheetReport, profileVM.user.firstName!), style: .Destructive) { _ in
            self.reportUser(sender)
        }
        sheet.addAction(LS(.moreSheetCancel), style: .Cancel)
        presentViewController(sheet)
    }
    
    @IBAction func reportUser(sender: AnyObject) {
        let alert = UIAlertController(title: LS(.reportAlertTitle), message: LS(.reportAlertMessage), preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler(nil)
        alert.addAction(LS(.reportAlertCancel), style: .Cancel)
        alert.addAction(LS(.reportAlertConfirm), style: .Destructive) { _ in
            if let reportReason = (alert.textFields?[0] as? UITextField)?.text {
                Meteor.reportUser(self.profileVM.user, reason: reportReason)
            }
        }
        presentViewController(alert)
    }
}