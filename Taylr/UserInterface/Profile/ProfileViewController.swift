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

    @IBOutlet weak var tableView: UITableView!
    var mainCell: ProfileMainCell!
    var user : User!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainCell = tableView.dequeueReusableCellWithIdentifier("ProfileMainCell") as! ProfileMainCell
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        mainCell.user = user
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
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

extension ProfileViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return mainCell
        }
        return tableView.dequeueReusableCellWithIdentifier("") as! UITableViewCell
    }
}

extension ProfileViewController : UITableViewDelegate {
    
}

// MARK: ScrollView Delegate

extension ProfileViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        if (yOffset < 0) {
            let imageView = mainCell.coverImageView
            var frame = imageView.frame
            frame.origin.y = yOffset
            frame.size.height = mainCell.coverImageHeight.constant + -yOffset
            imageView.frame = frame
        }
    }
}