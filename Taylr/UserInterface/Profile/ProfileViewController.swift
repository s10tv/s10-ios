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
import Core

class ProfileViewController : BaseViewController {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarView: UserAvatarView!
    @IBOutlet weak var aboutLabel: DesignableLabel!
    
    var user : User!
    
    override func viewDidLoad() {
        assert(user != nil, "Must set user before attempt to loading ProfileVC")
        super.viewDidLoad()
        coverImageView.clipsToBounds = true
        // TODO: Find better solution than hardcoding keypath string
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
    
//    override func updateViewConstraints() {
//        constrain(backButton, moreButton, view.superview!) { backButton, moreButton, superview in
//            backButton.top == superview.top
//            moreButton.top == superview.top
//        }
//        super.updateViewConstraints()
//    }
//    
//    override func viewDidLayoutSubviews() {
//        // Automatic preferredMaxLayoutWidth does not seem to work
//        // when label is laid out relative to scroll view contentSize
//        aboutLabel.preferredMaxLayoutWidth = aboutLabel.frame.width
//        super.viewDidLayoutSubviews()
//    }
    
    // MARK: - Action
    
    @IBAction func showMoreOptions(sender: AnyObject) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        sheet.addAction(LS(.moreSheetReport, user!.firstName!), style: .Destructive) { _ in
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
                Meteor.reportUser(self.user, reason: reportReason)
            }
        }
        presentViewController(alert)
    }
}
