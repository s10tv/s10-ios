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
    var coverCell: ProfileCoverCell!
    var vm: ProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 500
        
        let coverSection = vm.coverVM.map { [unowned self] (coverVM, index) -> UITableViewCell in
            if self.coverCell == nil {
                self.coverCell = self.tableView.dequeueReusableCellWithIdentifier(.ProfileCoverCell,
                forIndexPath: NSIndexPath(forRow: index, inSection: 0)) as! ProfileCoverCell
                self.coverCell.bind(coverVM)
            }
            return self.coverCell
        }
        let infoSection = vm.infoVM.map { [unowned self] (infoVM, index) -> UITableViewCell in
            if let infoVM = infoVM as? TaylrProfileInfoViewModel {
                let cell = self.tableView.dequeueReusableCellWithIdentifier(.TaylrProfileInfoCell,
                                forIndexPath: NSIndexPath(forRow: index, inSection: 1)) as! TaylrProfileInfoCell
                cell.bind(infoVM)
                return cell
            }
            if let infoVM = infoVM as? ConnectedProfileInfoViewModel {
//                let cell = self.tableView.dequeueReusableCellWithIdentifier(.TaylrProfileInfoCell,
//                    forIndexPath: NSIndexPath(forRow: index, inSection: 1)) as! TaylrProfileInfoCell
//                cell.bind(infoVM)
//                return cell
            }
            fatalError("Unexpected infoVM type")
//            let cell = self.tableView.dequeueReusableCellWithIdentifier(.Profile,
//                forIndexPath: NSIndexPath(forRow: index, inSection: 1)) as! ProfileSelectorRowCell
//            cell.bind(vm.profiles)
//            return cell
        }
//        let activitiesSection = vm.activities.map { [unowned self] (activity, index) -> UITableViewCell in
//            let cell = self.tableView.dequeueReusableCellWithIdentifier(.ImageCell,
//                forIndexPath: NSIndexPath(forRow: index, inSection: 2)) as! ActivityImageCell
//            cell.activity = activity
//            return cell
//        }
        DynamicArray([coverSection, infoSection/*, activitiesSection*/]) ->> tableView
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
            vc.vm = vm.conversationVM()
        }
    }
    
    // MARK: - Action
    
    @IBAction func showMoreOptions(sender: AnyObject) {
//        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
//        sheet.addAction(LS(.moreSheetReport, vm.coverVM.firstName.value), style: .Destructive) { _ in
//            self.reportUser(sender)
//        }
//        sheet.addAction(LS(.moreSheetCancel), style: .Cancel)
//        presentViewController(sheet)
    }
    
    @IBAction func reportUser(sender: AnyObject) {
//        let alert = UIAlertController(title: LS(.reportAlertTitle), message: LS(.reportAlertMessage), preferredStyle: .Alert)
//        alert.addTextFieldWithConfigurationHandler(nil)
//        alert.addAction(LS(.reportAlertCancel), style: .Cancel)
//        alert.addAction(LS(.reportAlertConfirm), style: .Destructive) { _ in
//            if let reportReason = (alert.textFields?[0] as? UITextField)?.text {
//                Meteor.reportUser(self.vm.user, reason: reportReason)
//            }
//        }
//        presentViewController(alert)
    }
}

extension ProfileViewController : UITableViewDelegate {
    
}

// MARK: ScrollView Delegate

extension ProfileViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        if (yOffset < 0) {
            let imageView = coverCell.coverImageView
            var frame = imageView.frame
            frame.origin.y = yOffset
            frame.size.height = coverCell.coverImageHeight.constant + -yOffset
            imageView.frame = frame
            coverCell.coverOverlay.frame = frame
        }
    }
}