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

    @IBOutlet weak var tableView: UITableView!
    var dataSourceBond: UITableViewDataSourceBond<UITableViewCell>!
    var mainCell: ProfileMainCell!
    var profileVM: ProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        
        dataSourceBond = UITableViewDataSourceBond(tableView: tableView, disableAnimation: false)
        let mainSection = DynamicArray([profileVM.user]).map { [unowned self] (user, index) -> UITableViewCell in
            self.mainCell = self.tableView.dequeueReusableCellWithIdentifier(.ProfileMainCell,
                forIndexPath: NSIndexPath(forRow: index, inSection: 0)) as! ProfileMainCell
            self.mainCell.user = user
            return self.mainCell
        }
        let activitiesSection = profileVM.activities.map { [unowned self] (activity, index) -> UITableViewCell in
            let cell = self.tableView.dequeueReusableCellWithIdentifier(.ImageCell,
                forIndexPath: NSIndexPath(forRow: index, inSection: 1)) as! ProfileImageCell
            cell.activity = activity
            return cell
        }
        DynamicArray([mainSection, activitiesSection]) ->> dataSourceBond
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