//
//  ConversationViewController.swift
//  S10
//
//  Created by Tony Xiao on 10/17/15.
//  Copyright © 2015 S10. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Atlas
import SwipeView
import Core

class ConversationViewController : UIViewController {
    
    enum Page : Int {
        case ChatHistory = 0, Producer = 1
    }

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var swipeView: SwipeView!
    @IBOutlet weak var producerContainer: UIView!
    @IBOutlet weak var chatHistoryContainer: UIView!
    
    private(set) var chatHistoryVC: ConversationHistoryViewController!
    private(set) var producerVC: ProducerViewController!
    private(set) var receiveVC: ReceiveViewController!
    
    var vm: ConversationViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coverImageView.sd_image <~ vm.cover
        avatarImageView.sd_image <~ vm.avatar
        titleLabel.rac_text <~ vm.displayName
        statusLabel.rac_text <~ vm.displayStatus
        
        let sb = UIStoryboard(name: "Conversation", bundle: nil)
        
        receiveVC = sb.instantiateViewControllerWithIdentifier("Receive") as! ReceiveViewController
        receiveVC.vm = vm.receiveVM()
        receiveVC.delegate = self
        
        chatHistoryVC = sb.instantiateViewControllerWithIdentifier("ChatHistory") as! ConversationHistoryViewController
        chatHistoryVC.layerClient = MainContext.layer.layerClient
        chatHistoryVC.marksMessagesAsRead = false
        chatHistoryVC.vm = vm
        chatHistoryVC.delegate = self
        chatHistoryVC.historyDelegate = self
        
        producerVC = sb.instantiateViewControllerWithIdentifier("Producer") as! ProducerViewController
        producerVC.producerDelegate = self
        
        addChildViewController(chatHistoryVC)
        chatHistoryContainer.addSubview(chatHistoryVC.view)
        chatHistoryVC.view.makeEdgesEqualTo(chatHistoryContainer)
        chatHistoryVC.didMoveToParentViewController(self)
        
        addChildViewController(producerVC)
        producerContainer.insertSubview(producerVC.view, atIndex: 0)
        producerVC.view.makeEdgesEqualTo(producerContainer)
        producerVC.didMoveToParentViewController(self)
        
        [chatHistoryContainer, producerContainer].each {
            $0.bounds = view.bounds
            $0.removeFromSuperview()
            $0.translatesAutoresizingMaskIntoConstraints = true
        }
        
        swipeView.vertical = true
        swipeView.bounces = false
        swipeView.currentItemIndex = Page.Producer.rawValue
        swipeView.dataSource = self
        swipeView.delegate = self
        swipeView.layoutIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // #temp hack till we figure out better way
        let scrollView = swipeView.valueForKey("scrollView") as! UIScrollView
        scrollView.contentInset.top = 0
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundColor(UIColor(white: 0.5, alpha: 0.4))
        if let view = navigationItem.titleView {
            view.bounds.size = view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.setBackgroundColor(nil)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if navigationController?.lastViewController is ProfileViewController {
            navigationController?.popViewControllerAnimated(true)
            return false
        }
        return super.shouldPerformSegueWithIdentifier(identifier, sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ProfileViewController {
            vc.vm = vm.profileVM()
        }
    }
    
    // MARK: -
    
    @IBAction func switchToHistory(sender: AnyObject) {
//        overlayVC = nil
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

// MARK: - Video Producer

extension ConversationViewController : ProducerDelegate {
    func producerWillStartRecording(producer: ProducerViewController) {
    }
    
    func producerDidCancelRecording(producer: ProducerViewController) {
    }
    
    func producer(producer: ProducerViewController, didProduceVideo video: VideoSession, duration: NSTimeInterval) {
        wrapFuture(showProgress: true) {
            video.exportWithFirstFrame().onSuccess { (url, thumbnail) in
                Analytics.track("Message: Send", ["ConversationName": self.vm.displayName.value])
                self.vm.sendVideo(url, thumbnail: thumbnail, duration: duration)
            }
        }
    }
}

// MARK: - Chat History

extension ConversationViewController : ATLConversationViewControllerDelegate {
    func conversationViewController(viewController: ATLConversationViewController!, didSelectMessage message: LYRMessage!) {
        if let video = vm.videoForMessage(message) {
            receiveVC.vm.playlist.array = [video]
            presentViewController(receiveVC, animated: false)
        }
    }
}

extension ConversationViewController : ConversationHistoryDelegate {
    func didTapOnCameraButton() {
        swipeView.scrollToPage(Page.Producer.rawValue, duration: 0.25)
    }
}

// MARK: - Video Player

extension ConversationViewController : ReceiveViewControllerDelegate {
    func didFinishPlaylist(receiveVC: ReceiveViewController) {
//        overlayVC = producerVC
        // TODO: This semantic is not correct for non-text based messages
        vm.markAllMessagesAsRead()
        receiveVC.dismissViewController(animated: false)
    }
}

// MARK: - SwipeView

extension ConversationViewController : SwipeViewDataSource {
    func numberOfItemsInSwipeView(swipeView: SwipeView!) -> Int {
        return 2
    }
    
    func swipeView(swipeView: SwipeView!, viewForItemAtIndex index: Int, reusingView view: UIView!) -> UIView! {
        return index == Page.ChatHistory.rawValue ? chatHistoryContainer : producerContainer
    }
}

extension ConversationViewController : SwipeViewDelegate {
}