//
//  ChatViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import ReactiveCocoa
import JSQMessagesViewController

class ChatViewController : JSQMessagesViewController {
    
    // TODO: Make chatVC inherit from our BaseVC
//        allowedStates = [.BoatSailed, .NewGame]
    
    private var viewModel: MessagesViewModel!
    var connection: Connection?
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var avatarView: UserAvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var outgoingBubble : JSQMessagesBubbleImage!
    var incomingBubble : JSQMessagesBubbleImage!
    var disposable: RACDisposable?

    func customizeAppearance() {
        // TODO: Make this configurable from storyboard. JSQMessages library annoyingly
        // resets its own color to white when configuring itself
        view.backgroundColor = StyleKit.white
        collectionView.backgroundColor = UIColor.clearColor()
        
        // Customize input views
        inputToolbar.contentView.leftBarButtonItem = nil
        inputToolbar.contentView.textView.font = UIFont(.transatTextStandard, size: 16)
        let sendButton = inputToolbar.contentView.rightBarButtonItem
        sendButton.setTitleColor(StyleKit.brandBlue, forState: .Normal)
        sendButton.setTitleColor(StyleKit.brandBlue.jsq_colorByDarkeningColorWithValue(0.1), forState: .Highlighted)
        sendButton.tintColor = StyleKit.brandBlue
        sendButton.titleLabel?.font = UIFont(.transatTextBold, size: 17)
        
        // Customize chat bubble
        // Magic insets number copied from inside StyleKit for imageOfChatBubble
        let magicInsets = UIEdgeInsetsMake(24, 19, 10, 28)
        let bubbleFactory = JSQMessagesBubbleImageFactory(bubbleImage: StyleKit.imageOfChatBubble, capInsets: magicInsets)
        outgoingBubble = bubbleFactory.outgoingMessagesBubbleImageWithColor(StyleKit.navy35)
        incomingBubble = bubbleFactory.incomingMessagesBubbleImageWithColor(StyleKit.pureWhite)
        
        // Customize layout
        let layout = collectionView.collectionViewLayout
//        layout.springinessEnabled = true
        layout.incomingAvatarViewSize = CGSizeZero
        layout.outgoingAvatarViewSize = CGSizeZero
        layout.messageBubbleFont = UIFont(.transatTextStandard, size: 17)
        // WARNING: Careful with adjusting the following two values. The combination of them allows text to be centered
        // within the avatar bubble and simultaneously empirically prevent the last line from being cutoff (for multiline)
        layout.messageBubbleExtraVerticalSpace = 5
        layout.messageBubbleTextViewTextContainerInsets = UIEdgeInsets(top: 11, left: 14, bottom: 0, right: 14)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(connection != nil, "Connection must be set before attempting to load chat")
        viewModel = MessagesViewModel(connection: connection!, delegate: self)
        
        nameLabel.text = viewModel.recipient.firstName
        avatarView.user = viewModel.recipient
        
         // TODO: Make subclass of UIControl and use target-action
        titleView.userInteractionEnabled = true
        titleView.whenTapEnded { [weak self] in self!.performSegue(.ChatToProfile) }

        customizeAppearance()
    }
    
    // TODO: This is not at all kosher with view controller lifecycle management, especially around interactive
    // transitioning. Figure out a better way to do this.
    override func viewWillAppear(animated: Bool) {
        // NOTE: Super's implementation causes collectionView to reload, thus the following initialization hack
        viewModel.loadMessages()
        super.viewWillAppear(animated)
        
        // Defer from viewDidLoad. Hack to get multi-line prompt to show up properly and enable send button
        if let promptText = viewModel.promptText() {
            jsq_addObservers()
            inputToolbar.contentView.textView.text = promptText
            inputToolbar.toggleSendButtonEnabled()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        disposable = RACObserve(connection!, ConnectionAttributes.hasUnreadMessage.rawValue)
            .subscribeNext { [weak self] _ in self!.viewModel.markAsRead() }
        // TODO: make this generic
        if connection?.isCrabConnection == true {
            Analytics.track("Screen: ChatCrab")
        } else {
            Analytics.track("Screen: Chat")
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        disposable?.dispose()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let profileVC = segue.destinationViewController as? ProfileViewController {
            profileVC.user = viewModel.recipient
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: -
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        Log.debug("Will send message and then reload collection view")
        viewModel.sendMessage(text)
        finishSendingMessageAnimated(true)
    }
    
    // MARK: - Class Method
    
    override class func nib() -> UINib? {
        return nil
    }
}

// MARK: - JSQMessagesCollectionViewDataSource

extension ChatViewController : JSQMessagesCollectionViewDataSource {
    func senderDisplayName() -> String! {
        return viewModel.sender.displayName
    }
    
    func senderId() -> String! {
        return viewModel.sender.documentID
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        assert(section == 0, "Only 1 section is supported in chat")
        return viewModel.numberOfMessages()
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell
        cell.textView.textColor = viewModel.messageAtIndex(indexPath.row).outgoing ? StyleKit.white : StyleKit.navy
        cell.textView.linkTextAttributes = [
            NSForegroundColorAttributeName: StyleKit.teal,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
        ]
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return viewModel.messageAtIndex(indexPath.row).jsqMessage()
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        return viewModel.messageAtIndex(indexPath.row).outgoing ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return viewModel.messageAtIndex(indexPath.row).sender?.jsqAvatar()
    }
    
    // Message Timestamp
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        return viewModel.displayTimestampForMessageAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if let str = self.collectionView(collectionView, attributedTextForCellTopLabelAtIndexPath: indexPath) {
            return str.boundingRectWithSize(CGSize(side: 1000), options: .UsesFontLeading, context: nil).height
        }
        return 0
    }
    
    // Read Receipt
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        return viewModel.displayReadDateForMessageAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if let str = self.collectionView(collectionView, attributedTextForCellBottomLabelAtIndexPath: indexPath) {
            return str.boundingRectWithSize(CGSize(side: 1000), options: .UsesFontLeading, context: nil).height
        }
        return 0
    }
}

extension ChatViewController : MessagesViewModelDelegate {
    func viewModel(viewModel: MessagesViewModel, didChangeMessages messages: [Message]) {
        Log.debug("Finish receiving message, will reload collection view")
        finishReceivingMessageAnimated(true)
    }
}