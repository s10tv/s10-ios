//
//  ProfileViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/27/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Cartography
import Core

class ProfileViewController : BaseViewController {
    
    enum Section : Int {
        case Cover = 0
        case Info = 1
        case Activities = 2
    }

    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var coverCell: ProfileCoverCell!
    var vm: ProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 500
        moreButton.hidden = !vm.showMoreOptions
        messageButton.hidden = !vm.allowMessage
        messageButton.rac_title <~ vm.timeRemaining
        tableView.dataSource = self
        
        // TODO: Refactor into separate binding & handle more granular changes
        vm.infoVM.producer.startWithNext { [weak self] _ in
            self?.tableView.reloadData()
//            self?.tableView.reloadSections(NSIndexSet(index: Section.Info.rawValue), withRowAnimation: .Automatic)
        }
        vm.activities.changes.observeNext { [weak self] _ in
            self?.tableView.reloadData()
//            self?.tableView.reloadSections(NSIndexSet(index: Section.Activities.rawValue), withRowAnimation: .Automatic)
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.track("View: Profile")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bottomInset = messageButton.hidden ? 0 : messageButton.frame.height
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if navigationController?.lastViewController is ConversationViewController {
            navigationController?.popViewControllerAnimated(true)
            return false
        }
        return super.shouldPerformSegueWithIdentifier(identifier, sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ConversationViewController {
            vc.layerClient = MainContext.layer.layerClient
            vc.vm = vm.conversationVM()
            Analytics.track("Profile: TapMessage")
        }
    }
    
    // MARK: - Action
    
    // Very repetitive. Consider refactor along with ConversationViewController
    @IBAction func showMoreOptions(sender: AnyObject) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        sheet.addAction(LS(.moreSheetBlock, vm.coverVM.firstName.value), style: .Destructive) { _ in
            self.blockUser(self)
        }
        sheet.addAction(LS(.moreSheetReport, vm.coverVM.firstName.value), style: .Destructive) { _ in
            self.reportUser(self)
        }
        sheet.addAction(LS(.moreSheetCancel), style: .Cancel)
        presentViewController(sheet)
    }

    // TODO: FIX CODE DUPLICATION WITH ConversationViewController
    @IBAction func blockUser(sender: AnyObject) {
        let alert = UIAlertController(title: "Block User", message: "Are you sure you want to block \(vm.coverVM.firstName.value)?", preferredStyle: .Alert)
        alert.addAction("Cancel", style: .Cancel)
        alert.addAction("Block", style: .Destructive) { _ in
            self.vm.blockUser()

            let dialog = UIAlertController(title: "Block User", message: "\(self.vm.coverVM.firstName.value) will no longer be able to contact you in the future", preferredStyle: .Alert)
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
                self.vm.reportUser(reportReason)
            }
        }
        presentViewController(alert)
    }
}

extension ProfileViewController : UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .Cover: return 1
        case .Info: return 1
        case .Activities: return vm.activities.array.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .Cover:
            if coverCell == nil {
                coverCell = tableView.dequeue(ProfileCoverCell.self, indexPath: indexPath, vm: vm.coverVM)
            }
            return coverCell
        case .Info:
            switch vm.infoVM.value {
            case let vm as TaylrProfileInfoViewModel:
                return tableView.dequeue(TaylrProfileInfoCell.self, indexPath: indexPath, vm: vm)
            case let vm as ConnectedProfileInfoViewModel:
                return tableView.dequeue(ConnectedProfileInfoCell.self, indexPath: indexPath, vm: vm)
            default:
                fatalError("Unexpected cell type")
            }
        case .Activities:
            switch vm.activities[indexPath.row] {
            case let vm as ActivityImageViewModel:
                return tableView.dequeue(ActivityImageCell.self, indexPath: indexPath, vm: vm)
            case let vm as ActivityTextViewModel:
                return tableView.dequeue(ActivityTextCell.self, indexPath: indexPath, vm: vm)
            default:
                fatalError("Unexpected cell type")
            }
        }
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