//
//  ConversationViewController.swift
//  S10
//
//  Created by Tony Xiao on 10/17/15.
//  Copyright © 2015 S10. All rights reserved.
//

import UIKit
import CocoaLumberjack
import ReactiveCocoa
import NKRecorder
import SwipeView
import Atlas
import SVProgressHUD

class ConversationViewController : UIViewController {
    
    enum Page : Int {
        case ChatHistory = 0, Producer = 1
    }

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var swipeView: SwipeView!
    @IBOutlet weak var scrollDownHint: UIView!
    @IBOutlet var producerContainer: UIView!
    @IBOutlet var chatHistoryContainer: UIView!
    
    var scrollView: UIScrollView {
        return swipeView.valueForKey("scrollView") as! UIScrollView
    }
    
    private(set) var chatHistory: ChatHistoryViewController!
    private(set) var videoMaker: VideoMakerViewController!
    private(set) var videoPlayer: VideoPlayerViewController!
    
    var vm: ConversationViewModel!
    
    deinit {
        DDLogVerbose("ConversationVC deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coverImageView.rac_imageURL <~ vm.cover
        avatarImageView.rac_imageURL <~ vm.avatar
        titleLabel.rac_text <~ vm.displayName
        statusLabel.rac_text <~ vm.displayStatus
        spinner.rac_animating <~ vm.isBusy
        
        let sb = UIStoryboard(name: "Conversation", bundle: nil)
        
        videoPlayer = sb.instantiateViewControllerWithIdentifier("Receive") as! VideoPlayerViewController
        videoPlayer.vm = vm.videoPlayerVM
        videoPlayer.delegate = self
        
        chatHistory = sb.instantiateViewControllerWithIdentifier("ChatHistory") as! ChatHistoryViewController
        chatHistory.marksMessagesAsRead = false
        chatHistory.vm = vm
        chatHistory.delegate = self
        chatHistory.historyDelegate = self
        
        VideoMakerViewController.regularWeightFontName = R.Fonts.cabinRegular.rawValue
        VideoMakerViewController.mediumWeightFontName = R.Fonts.cabinMedium.rawValue
        VideoMakerViewController.boldWeightFontName = R.Fonts.cabinBold.rawValue
        videoMaker = VideoMakerViewController.mainController()
        videoMaker.videoMakerDelegate = self
        videoMaker.topOffset = 64.0
        
        addChildViewController(chatHistory)
        chatHistoryContainer.addSubview(chatHistory.view)
        chatHistory.view.makeEdgesEqualTo(chatHistoryContainer)
        chatHistory.didMoveToParentViewController(self)
        
        addChildViewController(videoMaker)
        producerContainer.insertSubview(videoMaker.view, atIndex: 0)
        videoMaker.view.makeEdgesEqualTo(producerContainer)
        videoMaker.didMoveToParentViewController(self)
        
        [chatHistoryContainer, producerContainer].each {
            $0.bounds = view.bounds
            $0.translatesAutoresizingMaskIntoConstraints = true
        }
        
        let page: Page = vm.hasUnreadText ? .ChatHistory : .Producer
        swipeView.vertical = true
        swipeView.bounces = false
        swipeView.dataSource = self
        swipeView.delegate = self
        swipeView.currentPage = page.rawValue
        
        if vm.hasUnplayedVideo {
            presentViewController(videoPlayer, animated: false, completion: nil)
        }
        DDLogVerbose("Finish viewDidLoad")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationBar.setBackgroundColor(UIColor(white: 0.5, alpha: 0.4))
        if let view = navigationBar.topItem?.titleView {
            view.bounds.size = view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        }
        DDLogVerbose("Finish viewWillAppear animated=\(animated)")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        DDLogVerbose("Finish viewDidAppear animated=\(animated)")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationBar.setBackgroundColor(nil)
        DDLogVerbose("Finish viewWillDisappear animated=\(animated)")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        DDLogVerbose("Finish viewDidDisappear animated=\(animated)")
    }
    
    // MARK: -

    @IBAction func didTapBackButton(sender: AnyObject) {
        // HACK ALERT: Due to NeactNative not calling viewWillDisappear at the right time
        // we have to manually make the textinput animate away as the view goes away
        // See https://app.asana.com/0/34520227311296/69398492475084
        chatHistory.view.resignFirstResponder()
        rnNavigationPop()
    }
    
    @IBAction func didTapScrollDownHint(sender: AnyObject) {
        swipeView.scrollToPage(Page.ChatHistory.rawValue, duration: 0.4)
    }
    
    @IBAction func didTapProfileView(sender: AnyObject) {
        if let user = vm.recipientUser()  {
            // Same hack as in didTapBackButton
            chatHistory.view.resignFirstResponder()
            rnNavigationPush(.Profile, args: [
                "userId": user.userId
            ])
        }
    }
    
    @IBAction func showMoreOptions(sender: AnyObject) {
        rnSendAppEvent(.ProfileShowMoreOptions, body: vm.recipientUser()?.userId)
    }
}

// MARK: - Video Producer

extension ConversationViewController : VideoMakerDelegate {
    
    func videoMakerWillStartRecording(videoMaker: VideoMakerViewController) {
        scrollDownHint.hidden = true
        scrollView.scrollEnabled = false
    }
    
    func videoMakerDidCancelRecording(videoMaker: VideoMakerViewController) {
        scrollDownHint.hidden = false
        scrollView.scrollEnabled = true
    }
    
    func videoMaker(videoMaker: VideoMakerViewController, didProduceVideoSession session: VideoSession) {
        SVProgressHUD.show()
        session.exportWithFirstFrame { url, thumbnail, duration in
            SVProgressHUD.dismiss()
            self.scrollDownHint.hidden = false
            self.scrollView.scrollEnabled = true
            self.vm.sendVideo(url, thumbnail: thumbnail, duration: duration)
            Analytics.track("Message: Send", properties: ["ConversationName": self.vm.displayName.value])
        }
    }
}

// MARK: - Chat History

extension ConversationViewController : ATLConversationViewControllerDelegate {
    func conversationViewController(viewController: ATLConversationViewController!, didSelectMessage message: LYRMessage!) {
        vm.ensureMessageAvailable(message)
        if let video = vm.videoForMessage(message) {
            videoPlayer.vm.playlist.array = [video]
            presentViewController(videoPlayer, animated: false, completion: nil)
        } else if message.videoPart != nil {
            Analytics.track("Conversation: TappedUnavailableVideo")
            showAlert("Video Downloading",
                message: "The video you requested is still downloading. Please try again later :(")
        }
    }
}

extension ConversationViewController : ConversationHistoryDelegate {
    func didTapOnCameraButton() {
        // CODE TO TEST SEND VIDEO
//        let name = ["v1", "v2", "v3", "v4"].randomElement()!
//        let videoURL = NSBundle.mainBundle().URLForResource(name, withExtension: "mp4")!
//        AVKit.exportFirstFrame(videoURL).onSuccess { thumbnail in
//            self.vm.sendVideo(videoURL, thumbnail: thumbnail, duration: 5)
//        }
        swipeView.scrollToPage(Page.Producer.rawValue, duration: 0.4)
    }
}

// MARK: - Video Player

extension ConversationViewController : VideoPlayerViewControllerDelegate {
    func videoPlayer(videoPlayer: VideoPlayerViewController, didPlayVideo video: Video) {
        vm.markMessageAsRead(video.identifier)
        Analytics.track("Message: Open", properties: [
            "MessageId": video.identifier
        ])
    }
    func videoPlayerDidFinishPlaylist(videoPlayer: VideoPlayerViewController) {
        // TODO: This semantic is not correct for non-text based messages
        videoPlayer.dismissViewControllerAnimated(false, completion: nil)
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
    
    func swipeViewCurrentItemIndexDidChange(swipeView: SwipeView!) {
        DDLogVerbose("SwipeView index changed index=\(swipeView.currentItemIndex)")
    }
}