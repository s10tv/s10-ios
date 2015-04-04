//
//  ChatViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import JSQMessagesViewController

@objc(ChatViewController)
class ChatViewController : JSQMessagesViewController {
    
    var connection: Connection?
    private var messages : FetchViewModel!
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var avatarView: UserAvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var outgoingBubbleData : JSQMessagesBubbleImage!
    var incomingBubbleData : JSQMessagesBubbleImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Make this configurable from storyboard. JSQMessages library annoyingly
        // resets its own color to white when configuring itself
        view.backgroundColor = nil
        collectionView.backgroundColor = nil
        
        inputToolbar.contentView.leftBarButtonItem = nil

        let bubbleFactory = JSQMessagesBubbleImageFactory()
        outgoingBubbleData = bubbleFactory.outgoingMessagesBubbleImageWithColor(StyleKit.darkWhite)
        incomingBubbleData = bubbleFactory.incomingMessagesBubbleImageWithColor(StyleKit.pureWhite)
    }
    
    override func viewWillAppear(animated: Bool) {
        // NOTE: Super's implementation causes collectionView to reload, thus the following initialization hack
        assert(connection != nil, "Connection being nil is not supported on chatVC")
        messages = FetchViewModel(frc: connection!.fetchMessages(sorted: true))
        messages.performFetchIfNeeded()
        super.viewWillAppear(animated)
        
        messages.signal.subscribeNext { [weak self] _ in
            // Surely there must be a way to do this one message at a time rather than
            // reloading the entire view?
            self?.collectionView.reloadData()
            self?.scrollToBottomAnimated(true)
            return
        }
        nameLabel.text = connection?.user?.firstName
        avatarView.user = connection?.user
        titleView.userInteractionEnabled = true
        titleView.whenTapped { [weak self] in
            self?.rootVC.showProfile((self?.connection?.user)!, animated: true)
            return
        }
        
        let avatarLength = 30
        let layout = collectionView.collectionViewLayout
        layout.incomingAvatarViewSize = CGSizeZero
        layout.outgoingAvatarViewSize = CGSizeZero
        layout.messageBubbleFont = UIFont(.TransatTextLight, size: 17)
        layout.springinessEnabled = true
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarView.makeCircular()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let profileVC = segue.destinationViewController as? ProfileViewController {
            profileVC.user = connection?.user
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func shouldShowTimestampForMessageAtIndexPath(indexPath: NSIndexPath) -> Bool {
        return indexPath.row % 3 == 0
    }
    
    // MARK: - 
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        if let connectionID = connection?.documentID {
            Core.meteor.callMethod("connection/sendMessage", params: [connectionID, text])
        }
        finishSendingMessageAnimated(true)
    }
    
    func senderDisplayName() -> String! {
        return User.currentUser()?.displayName
    }
    
    func senderId() -> String! {
        return User.currentUser()?.documentID
    }
    
    // MARK: - Class Method
    
    override class func nib() -> UINib {
        return UINib(nibName: "ChatView", bundle: nil)
    }
}

// MARK: - JSQMessagesCollectionViewDataSource

extension ChatViewController : JSQMessagesCollectionViewDataSource {
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.numberOfItemsInSection(section)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell
        // This doesn't work if layout changes (say diff avatar size). So need to figure out better way
        cell.avatarImageView.makeCircular()
        cell.textView.textColor = StyleKit.navy
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return (messages.itemAtIndexPath(indexPath) as Message).jsqMessage()
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages.itemAtIndexPath(indexPath) as Message
        return message.sender!.isCurrentUser ? outgoingBubbleData : incomingBubbleData
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages.itemAtIndexPath(indexPath) as Message
        return message.sender?.jsqAvatar();
    }
    
    // Message Timestamp
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if shouldShowTimestampForMessageAtIndexPath(indexPath) {
            let message = messages.itemAtIndexPath(indexPath) as Message
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.createdAt)
        }
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return shouldShowTimestampForMessageAtIndexPath(indexPath) ? 20 : 0
    }

}