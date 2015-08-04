//
//  ProfileViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/27/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import SDWebImage
import Cartography
import Bond
import Core

class ProfileViewController : BaseViewController {

    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var coverCell: ProfileCoverCell!
    var vm: ProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 500
        moreButton.hidden = !vm.showMoreOptions
        
        let coverFactory = tableView.factory(ProfileCoverCell)
        let taylrProfileFactory = tableView.factory(TaylrProfileInfoCell.self, section: 1)
        let connectedProfileFactory = tableView.factory(ConnectedProfileInfoCell.self, section: 1)
        let imageCellFactory = tableView.factory(ActivityImageCell.self, section: 2)
        let textCellFactory = tableView.factory(ActivityTextCell.self, section: 2)

        let coverSection = vm.coverVM.map { [unowned self] (vm, index) -> UITableViewCell in
            if self.coverCell == nil {
                self.coverCell = coverFactory(vm, index) as! ProfileCoverCell
            }
            return self.coverCell
        }
        let infoSection = vm.infoVM.map { [weak self] (vm, index) -> UITableViewCell in
            switch vm {
            case let vm as TaylrProfileInfoViewModel:
                return taylrProfileFactory(vm, index)
            case let vm as ConnectedProfileInfoViewModel:
                return connectedProfileFactory(vm, index)
            default:
                fatalError("Unexpected cell type")
            }
        }
        
        let activitiesSection = vm.activities.map { (vm, index) -> UITableViewCell in
            switch vm {
            case let vm as ActivityImageViewModel:
                return imageCellFactory(vm, index)
            case let vm as ActivityTextViewModel:
                return textCellFactory(vm, index)
            default:
                fatalError("Unexpected cell type")
            }
        }
        DynamicArray([coverSection, infoSection, activitiesSection]) ->> tableView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == SegueIdentifier.ProfileToConversation.rawValue
            && navigationController?.lastViewController is ConversationViewController {
                navigationController?.popViewControllerAnimated(true)
                return false
        }
        return super.shouldPerformSegueWithIdentifier(identifier, sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ConversationViewController {
            vc.vm = vm.conversationVM()
        }
    }
    
    // MARK: - Action
    
    // Very repetitive. Consider refactor along with ConversationViewController
    @IBAction func showMoreOptions(sender: AnyObject) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        sheet.addAction("Message \(vm.cvm.firstName.value)") { _ in
            self.performSegue(.ProfileToConversation)
        }
        sheet.addAction(LS(.moreSheetBlock, vm.cvm.firstName.value), style: .Destructive) { _ in
            self.blockUser(self)
        }
        sheet.addAction(LS(.moreSheetReport, vm.cvm.firstName.value), style: .Destructive) { _ in
            self.reportUser(self)
        }
        sheet.addAction(LS(.moreSheetCancel), style: .Cancel)
        presentViewController(sheet)
    }
    
    @IBAction func blockUser(sender: AnyObject) {
        let alert = UIAlertController(title: "Block User", message: "Are you sure you want to block \(vm.cvm.firstName.value)?", preferredStyle: .Alert)
        alert.addAction("Cancel", style: .Cancel)
        alert.addAction("Block", style: .Destructive) { _ in
            self.vm.blockUser()
        }
        presentViewController(alert)
    }
    
    @IBAction func reportUser(sender: AnyObject) {
        let alert = UIAlertController(title: LS(.reportAlertTitle), message: LS(.reportAlertMessage), preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler(nil)
        alert.addAction(LS(.reportAlertCancel), style: .Cancel)
        alert.addAction(LS(.reportAlertConfirm), style: .Destructive) { _ in
            if let reportReason = (alert.textFields?[0] as? UITextField)?.text {
                self.vm.reportUser(reportReason)
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
            let originalHeight = coverCell.frame.height - coverCell.collectionView.frame.height
            let imageView = coverCell.coverImageView
            var frame = imageView.frame
            frame.origin.y = yOffset
            frame.size.height = originalHeight + -yOffset
            imageView.frame = frame
            coverCell.coverOverlay.frame = frame
        }
    }
}