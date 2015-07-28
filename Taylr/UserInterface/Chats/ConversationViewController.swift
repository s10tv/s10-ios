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
import Bond
import Core
import Async

class ConversationViewController : BaseViewController {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var pageVC: UIPageViewController!
    var player: PlayerViewController!
    var producer: ProducerViewController!
    var vm: ConversationViewModel!


    override func viewDidLoad() {
        super.viewDidLoad()

        let avkit = UIStoryboard(name: "AVKit", bundle: nil)
        player = avkit.instantiateViewControllerWithIdentifier("Player") as! PlayerViewController
        player.interactor.delegate = self
        producer = avkit.instantiateViewControllerWithIdentifier("Producer") as! ProducerViewController
        producer.producerDelegate = self
        
        // TODO: Need to get rid of the delay when starting up
        pageVC.view.backgroundColor = UIColor.blackColor()
        pageVC.dataSource = self
        
        vm.reloadMessages()
        vm.avatar ->> avatarView.imageBond
        vm.displayName ->> nameLabel
        vm.busy ->> spinner
        vm.displayStatus ->> activityLabel
        
        showPlayer()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ProfileViewController {
            vc.vm = vm.profileVM()
        }
        if segue.matches(.ConversationPage) {
            pageVC = segue.destinationViewController as! UIPageViewController
        }
    }
    
    // MARK: - Actions
    
    func showPlayer(animated: Bool = false) {
        pageVC.setViewControllers([player], direction: .Reverse, animated: animated, completion: nil)
    }
    
    func showProducer(animated: Bool = false) {
        pageVC.setViewControllers([producer], direction: .Forward, animated: animated, completion: nil)
    }
    
    @IBAction func showMoreOptions(sender: AnyObject) {
//        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
//        sheet.addAction(LS(.moreSheetBlock, conversationVM.recipient.firstName!), style: .Destructive) { _ in
//            self.blockUser(sender)
//        }
//        sheet.addAction(LS(.moreSheetReport, conversationVM.recipient.firstName!), style: .Destructive) { _ in
//            self.reportUser(sender)
//        }
//        sheet.addAction(LS(.moreSheetCancel), style: .Cancel)
//        presentViewController(sheet)
    }
    
    @IBAction func blockUser(sender: AnyObject) {
//        let alert = UIAlertController(title: LS(.reportAlertTitle), message: LS(.reportAlertMessage), preferredStyle: .Alert)
//        alert.addAction(LS(.reportAlertCancel), style: .Cancel)
//        alert.addAction(LS(.reportAlertConfirm), style: .Destructive) { _ in
//            Meteor.blockUser(self.conversationVM.recipient)
//        }
//        presentViewController(alert)
    }
    
    @IBAction func reportUser(sender: AnyObject) {
//        let alert = UIAlertController(title: LS(.reportAlertTitle), message: LS(.reportAlertMessage), preferredStyle: .Alert)
//        alert.addTextFieldWithConfigurationHandler(nil)
//        alert.addAction(LS(.reportAlertCancel), style: .Cancel)
//        alert.addAction(LS(.reportAlertConfirm), style: .Destructive) { _ in
//            if let reportReason = (alert.textFields?[0] as? UITextField)?.text {
//                Meteor.reportUser(self.conversationVM.recipient, reason: reportReason)
//            }
//        }
//        presentViewController(alert)
    }
}

extension ConversationViewController : UIPageViewControllerDataSource {
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        return viewController == producer ? player : nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        return viewController == player ? producer : nil
    }
}

extension ConversationViewController : ProducerDelegate {
    
    func producerWillStartRecording(producer: ProducerViewController) {
//        conversationVM.recording.value = true
    }
    
    func producerDidCancelRecording(producer: ProducerViewController) {
//        conversationVM.recording.value = false
    }
    
    func producer(producer: ProducerViewController, didProduceVideo url: NSURL) {
//        conversationVM.recording.value = false
//        Log.info("I got a video \(url)")
//        Globals.taskService.uploadVideo(conversationVM.recipient, localVideoURL: url)
//        PKHUD.hide(animated: false)
    }
}

extension ConversationViewController : PlayerInteractorDelegate {
    func player(interactor: PlayerInteractor, didFinishVideo video: PlayableVideo) {
        if interactor.videoQueue.count == 0 {
            showProducer(animated: true)
        }
//        // TODO: Move into ViewModel
//        if let message = (video as? MessageViewModel)?.message
//            where message.fault == false // Hack for now to avoid EXC_BAD_INSTRUCTION
//                && message.sender != nil // Hack for now to avoid nil crash
//                && message.incoming && message.statusEnum != .Opened {
//            Meteor.openMessage(message, expireDelay: 0)
//            if let videoId = message.video?.documentID {
//                VideoCache.sharedInstance.removeVideo(videoId)
//            }
//        }
    }
}

//extension MessageViewModel : PlayableVideo {
//    var url: NSURL { return videoURL.value! }
//    var duration: NSTimeInterval { return 6 }
//    var timestamp: NSDate { return message.createdAt! }
//}