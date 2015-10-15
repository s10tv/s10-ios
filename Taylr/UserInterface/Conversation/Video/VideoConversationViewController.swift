//
//  ConversationViewController.swift
//  Taylr
//
//  Created by Tony Xiao on 6/14/15.
//  Copyright (c) 2015 Taylr. All rights reserved.
//

import Foundation
import ReactiveCocoa
import PKHUD
import Async
import SwipeView
import Core

class VideoConversationViewController : BaseViewController {
    enum Page : Int {
        case ChatHistory = 0
        case Producer = 1
    }

    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var swipeView: SwipeView!
    @IBOutlet weak var playerEmptyView: UIView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var newMessagesHint: UIView!
    @IBOutlet weak var receiveContainer: UIView!
    @IBOutlet var producerContainer: UIView!
    @IBOutlet var chatHistoryContainer: UIView!
    
    var receiver: ReceiveViewController!
    var chatHistory: ChatHistoryViewController!
    var producer: ProducerViewController!
    var vm: VideoConversationViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MAJOR TODO: Figure out how to unbind
        avatarView.sd_image <~ vm.avatar
        nameLabel.rac_text <~ vm.displayName
        spinner.rac_animating <~ vm.busy
        activityLabel.rac_text <~ vm.displayStatus
        newMessagesHint.rac_hidden <~ vm.hideNewMessagesHint
        coverImageView.sd_image <~ vm.cover
        
        let avkit = UIStoryboard(name: "Conversation", bundle: nil)
        receiver = avkit.instantiateViewControllerWithIdentifier("Receive") as! ReceiveViewController
        receiver.vm = vm.receiveVM
        receiver.delegate = self
        chatHistory = avkit.instantiateViewControllerWithIdentifier("ChatHistory") as! ChatHistoryViewController
        chatHistory.vm = vm.chatHistoryVM
        producer = avkit.instantiateViewControllerWithIdentifier("Producer") as! ProducerViewController
        producer.producerDelegate = self
        
        addChildViewController(receiver)
        receiveContainer.addSubview(receiver.view)
        receiver.view.makeEdgesEqualTo(receiveContainer)
        receiver.didMoveToParentViewController(self)
        
        addChildViewController(chatHistory)
        chatHistoryContainer.addSubview(chatHistory.view)
        chatHistory.view.makeEdgesEqualTo(chatHistoryContainer)
        chatHistory.didMoveToParentViewController(self)
        
        addChildViewController(producer)
        producerContainer.insertSubview(producer.view, atIndex: 0)
        producer.view.makeEdgesEqualTo(producerContainer)
        producer.didMoveToParentViewController(self)
        
        [chatHistoryContainer, producerContainer].each {
            $0.bounds = view.bounds
            $0.removeFromSuperview()
            $0.translatesAutoresizingMaskIntoConstraints = true
        }
    
        swipeView.vertical = true
        swipeView.bounces = false
        swipeView.currentItemIndex = vm.showTutorial ? Page.ChatHistory.rawValue
                                                     : Page.Producer.rawValue
        swipeView.dataSource = self
        swipeView.delegate = self
        swipeView.layoutIfNeeded()

        if vm.hasUnreadMessage.value {
            showReceiver()
        } else {
            hideReceiver()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.track("View: Conversation")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let scrollView = swipeView.valueForKey("scrollView") as! UIScrollView
        scrollView.contentInset = UIEdgeInsetsZero
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundColor(UIColor(white: 0.5, alpha: 0.4))
        if let view = navigationItem.titleView {
            view.bounds.size = view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        }
        navigationController?.interactivePopGestureRecognizer?.enabled = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.setBackgroundColor(nil)
        navigationController?.interactivePopGestureRecognizer?.enabled = true
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == SegueIdentifier.ConversationToProfile.rawValue
            && navigationController?.lastViewController is ProfileViewController {
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
    
    // MARK: Actions
    
    func showReceiver() {
        receiveContainer.hidden = false
        receiver.player.play()
    }
    
    func hideReceiver() {
        receiveContainer.hidden = true
    }
    
    func showPage(page: Page, animated: Bool = false) {
        swipeView.scrollToItemAtIndex(page.rawValue, duration: animated ? 0.25 : 0)
    }
    

    @IBAction func didTapLeave(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func didTapNewMessagesHint(sender: AnyObject) {
        showReceiver()
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

// MARK: - SwipeView Delegate & DataSource

extension VideoConversationViewController : SwipeViewDataSource {
    func numberOfItemsInSwipeView(swipeView: SwipeView!) -> Int {
        return 2
    }
    
    func swipeView(swipeView: SwipeView!, viewForItemAtIndex index: Int, reusingView view: UIView!) -> UIView! {
        return index == Page.ChatHistory.rawValue ? chatHistoryContainer : producerContainer
    }
}

extension VideoConversationViewController : SwipeViewDelegate {
    func swipeViewCurrentItemIndexDidChange(swipeView: SwipeView!) {
        if swipeView.currentItemIndex == Page.ChatHistory.rawValue {
            Analytics.track("Conversation: ViewChatHistory")
        } else if swipeView.currentItemIndex == Page.Producer.rawValue {
            vm.finishTutorial()
        }
    }
}

// MARK: - Producer Delegate

extension VideoConversationViewController : ProducerDelegate {
    func producerWillStartRecording(producer: ProducerViewController) {
        Analytics.track("Message: Start", ["ConversationName": vm.displayName.value])
        vm.recording.value = true
    }

    func producerDidCancelRecording(producer: ProducerViewController) {
        Analytics.track("Message: Discard", ["ConversationName": vm.displayName.value])
        vm.recording.value = false
    }
    
    func producer(producer: ProducerViewController, didProduceVideo session: VideoSession, duration: NSTimeInterval) {
        vm.recording.value = false
        wrapFuture(showProgress: true) {
            session.exportWithFirstFrame().onSuccess { (url, thumbnail) in
                var video = Video(url)
                video.thumbnail = Image(thumbnail)
                video.duration = duration
                Analytics.track("Message: Send", ["ConversationName": self.vm.displayName.value])
                self.vm.sendVideo(video)
            }
        }
    }
}

extension VideoConversationViewController : ReceiveViewControllerDelegate {
    func didFinishPlaylist(receiveVC: ReceiveViewController) {
        hideReceiver()
    }
}
