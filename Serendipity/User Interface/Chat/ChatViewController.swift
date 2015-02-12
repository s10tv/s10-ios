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

class ChatViewController : JSQMessagesViewController, JSQMessagesCollectionViewDataSource {
    
    var connection: Connection?
    private var messages : FetchViewModel!
    
    @IBOutlet var titleView: UIView!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var outgoingBubbleData : JSQMessagesBubbleImage!
    var incomingBubbleData : JSQMessagesBubbleImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        outgoingBubbleData = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        incomingBubbleData = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
        
        assert(connection != nil, "Connection being nil is not supported on chatVC")
        
        messages = FetchViewModel(frc: connection!.fetchMessages(sorted: true))
        messages.performFetchIfNeeded()
        messages.signal.subscribeNext { _ in
            self.collectionView.reloadData()
            return
        }
        

        avatarView.sd_setImageWithURL(connection?.user?.profilePhotoURL)
        nameLabel.text = connection?.user?.firstName
        titleView.whenTapped { [weak self] in
            // TODO: Avoid hard-coding segue identifier somehow
            self!.performSegueWithIdentifier("ChatToProfile", sender: nil)
        }
        
        navigationItem.titleView = titleView
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
    
    // MARK: - 
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        // TODO: Put this inside Messaging Service
        let message = Message.create() as Message
        message.connection = connection
        message.sender = User.currentUser()
        message.text = text
        message.save()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        // TODO: Remove accessory button all together
    }
    
    // MARK: - JSQMessagesCollectionViewDataSource
    
    func senderDisplayName() -> String! {
        return User.currentUser()?.firstName
    }
    
    func senderId() -> String! {
        return User.currentUser()?.documentID
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.numberOfItemsInSection(section)
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
        return nil;
    }
    
}
