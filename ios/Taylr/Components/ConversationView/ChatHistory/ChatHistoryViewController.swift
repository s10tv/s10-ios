//
//  ChatHistoryViewController.swift
//  S10
//
//  Created by Tony Xiao on 10/14/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Atlas

protocol ConversationHistoryDelegate: class {
    func didTapOnCameraButton()
}

class ChatHistoryViewController : ATLConversationViewController {
    
    weak var historyDelegate: ConversationHistoryDelegate?
    
    var vm: ConversationViewModel! {
        didSet {
            layerClient = vm.layer.layerClient
            conversation = vm.conversation
        }
    }
    var ctx: Context!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clearColor()
        messageInputToolbar.textInputView.font = UIFont(.cabinRegular, size: 17)
        
        // Slight hacky to configure typing indicator appearance
        let label = typingIndicatorController.valueForKey("label") as! UILabel
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(.cabinRegular, size: 12)
        let gradientLayer = typingIndicatorController.valueForKey("backgroundGradientLayer") as! CAGradientLayer
        gradientLayer.colors = [
            UIColor(white: 0, alpha: 0).CGColor,
            UIColor(white: 0, alpha: 0.75).CGColor,
            UIColor(white: 0, alpha: 0).CGColor
        ]
        
        dataSource = vm
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // #temp hack till we figure out better way
        collectionView.contentInset.top = 64
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // NOTE: Fix for messageInputToolbar not appearing sometimes if switching between chatHistory
        // and videoMaker too fast
        view.resignFirstResponder() // HACKIER FIX for when message does not show up
        view.becomeFirstResponder()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        vm.markAllNonVideoMessagesAsRead()
    }
    
    override func sendLocationMessage() {
        let alert = UIAlertController(title: "Share Location", message: "Please confirm that you would like to share your location.", preferredStyle: .Alert)
        alert.addAction("Cancel", style: .Cancel)
        alert.addAction("Send", style: .Default) { _ in
            super.sendLocationMessage()
        }
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // override (superclass implement this, but not visible to subclass because)
    // it's not declared in the header file
    func messageInputToolbar(messageInputToolbar: ATLMessageInputToolbar!, didTapLeftAccessoryButton leftAccessoryButton: UIButton!) {
        historyDelegate?.didTapOnCameraButton()
    }
}

// MARK: - ATLConversationViewControllerDataSource

extension ConversationViewModel : ATLConversationViewControllerDataSource {
    
    public func conversationViewController(conversationViewController: ATLConversationViewController!, participantForIdentifier participantIdentifier: String!) -> ATLParticipant! {
        return getParticipant(participantIdentifier)
    }
    
    public func conversationViewController(conversationViewController: ATLConversationViewController!, attributedStringForDisplayOfDate date: NSDate!) -> NSAttributedString! {
        return Formatters.attributedStringForDate(date)
    }
    
    public func conversationViewController(conversationViewController: ATLConversationViewController!, attributedStringForDisplayOfRecipientStatus recipientStatus: [NSObject : AnyObject]!) -> NSAttributedString! {
        return Formatters.attributedStringForDisplayOfRecipientStatus(recipientStatus, currentUser: currentUser)
    }
    
}

extension ConversationViewModel : ATLConversationViewControllerDelegate {
    public func conversationViewController(conversationViewController: ATLConversationViewController!, configureCell cell: UICollectionViewCell!, forMessage message: LYRMessage!) {
        
    }
}