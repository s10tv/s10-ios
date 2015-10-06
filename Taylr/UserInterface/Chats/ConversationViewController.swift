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

class ConversationViewController : BaseViewController {

    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var swipeView: SwipeView!
    @IBOutlet weak var playerEmptyView: UIView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var newMessagesHint: UIView!
    @IBOutlet var producerContainer: UIView!
    @IBOutlet var playerContainer: UIView!
    @IBOutlet var tutorialContainer: UIView!
    
    var player: PlayerViewController!
    var producer: ProducerViewController!
    var tutorial: ConversationTutorialViewController!
    var vm: ConversationViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MAJOR TODO: Figure out how to unbind
        avatarView.sd_image <~ vm.avatar
        nameLabel.rac_text <~ vm.displayName
        spinner.rac_animating <~ vm.busy
        activityLabel.rac_text <~ vm.displayStatus
        newMessagesHint.rac_hidden <~ vm.hideNewMessagesHint
        coverImageView.sd_image <~ vm.cover
        
        let avkit = UIStoryboard(name: "AVKit", bundle: nil)
        producer = avkit.instantiateViewControllerWithIdentifier("Producer") as! ProducerViewController
        producer.producerDelegate = self
        player = avkit.instantiateViewControllerWithIdentifier("Player") as! PlayerViewController
        player.vm.delegate = self
        player.vm.playlist <~ (vm.messages.producer.map {
            $0.map { (msg: MessageViewModel) in msg as MessageViewModel }
        })
        vm.playing <~ player.vm.isPlaying
        
        addChildViewController(player)
        playerContainer.addSubview(player.view)
        player.view.makeEdgesEqualTo(playerContainer)
        player.didMoveToParentViewController(self)
        
        addChildViewController(producer)
        producerContainer.insertSubview(producer.view, atIndex: 0)
        producer.view.makeEdgesEqualTo(producerContainer)
        producer.didMoveToParentViewController(self)
        
        [playerContainer, producerContainer].each {
            $0.bounds = view.bounds
            $0.removeFromSuperview()
            $0.translatesAutoresizingMaskIntoConstraints = true
        }
    
        swipeView.vertical = true
        swipeView.bounces = false
        swipeView.currentItemIndex = vm.page.value.rawValue
        swipeView.dataSource = self
        swipeView.delegate = self
        swipeView.layoutIfNeeded()
        
        if !vm.showTutorial {
            tutorialContainer.removeFromSuperview()
            player.autoplayNextUnread()
        } else {
            playerEmptyView.hidden = true
        }
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
        if let vc = segue.destinationViewController as? ConversationTutorialViewController {
            vc.delegate = self
        }
    }
    
    // MARK: Actions
    
    func showPage(page: ConversationViewModel.Page, animated: Bool = false) {
        swipeView.scrollToItemAtIndex(page.rawValue, duration: animated ? 0.25 : 0)
    }
    

    @IBAction func didTapLeave(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func didTapNewMessagesHint(sender: AnyObject) {
        showPage(.Player, animated: true)
    }
    
    @IBAction func didTapReplay(sender: AnyObject) {
        // TODO: maybe better method name to better align with semantic?
        player.advance()
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
                self.vm.reportUser(reportReason)
            }
        }
        presentViewController(alert)
    }
}

// MARK: - Tutorial

extension ConversationViewController : ConversationTutorialDelegate {
    func tutorialDidFinish() {
        playerEmptyView.hidden = false
        tutorialContainer.removeFromSuperview()
        if player.vm.nextVideo() != nil {
            player.advance()
        }
        vm.finishTutorial()
    }
}

// MARK: - SwipeView Delegate & DataSource

extension ConversationViewController : SwipeViewDataSource {
    func numberOfItemsInSwipeView(swipeView: SwipeView!) -> Int {
        return 2
    }
    
    func swipeView(swipeView: SwipeView!, viewForItemAtIndex index: Int, reusingView view: UIView!) -> UIView! {
        return index == ConversationViewModel.Page.Player.rawValue ? playerContainer : producerContainer
    }
}

extension ConversationViewController : SwipeViewDelegate {
    func swipeViewCurrentItemIndexDidChange(swipeView: SwipeView!) {
        if swipeView.currentItemIndex == ConversationViewModel.Page.Player.rawValue {
            Globals.analyticsService.screen("Conversation - Player")
        } else if swipeView.currentItemIndex == ConversationViewModel.Page.Producer.rawValue {
            Globals.analyticsService.screen("Conversation - Recorder")
        }

        vm.page.value = ConversationViewModel.Page(rawValue: swipeView.currentItemIndex)!
    }
}

// MARK: - Producer Delegate

extension ConversationViewController : ProducerDelegate {
    func producerWillStartRecording(producer: ProducerViewController) {
        vm.recording.value = true
        Globals.analyticsService.track("Started Message")
    }

    func producerDidCancelRecording(producer: ProducerViewController) {
        vm.recording.value = false
    }
    
    func producer(producer: ProducerViewController, didProduceVideo session: VideoSession, duration: NSTimeInterval) {
        vm.recording.value = false
        wrapFuture(showProgress: true) {
            session.exportWithFirstFrame().onSuccess { (url, thumbnail) in
                var video = Video(url)
                video.thumbnail = Image(thumbnail)
                video.duration = duration
                self.vm.sendVideo(video)
            }
        }
    }
}

// MARK: - Player Delegate

extension ConversationViewController : PlayerDelegate {
    func playerDidFinishPlaylist(player: PlayerViewModel) {
        showPage(.Producer, animated: true)
    }
    
    func player(player: PlayerViewModel, willPlayVideo video: MessageViewModel) {
        vm.currentMessage.value = video
    }
    
    func player(player: PlayerViewModel, didPlayVideo video: MessageViewModel) {
        vm.currentMessage.value = nil
        Globals.analyticsService.track("Viewed Message", properties:[
            "messageId": video.messageId])
        if video.unread {
            vm.openMessage(video)
        }
    }
}
