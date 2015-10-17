//
//  ConversationHistoryViewController.swift
//  S10
//
//  Created by Tony Xiao on 10/14/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Atlas
import Core

class ConversationHistoryViewController : ATLConversationViewController {
    
    var vm: ConversationViewModel! {
        didSet { conversation = vm.conversation }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clearColor()
        messageInputToolbar.textInputView.font = UIFont(.cabinRegular, size: 17)
        dataSource = vm
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.contentInset = UIEdgeInsets(top: topLayoutGuide.length, left: 0,
                                                bottom: bottomLayoutGuide.length, right: 0)
    }
}

// MARK: - ATLConversationViewControllerDataSource

extension ConversationViewModel : ATLConversationViewControllerDataSource {
    
    public func conversationViewController(conversationViewController: ATLConversationViewController!, participantForIdentifier participantIdentifier: String!) -> ATLParticipant! {
        return getUser(participantIdentifier)
    }
    
    public func conversationViewController(conversationViewController: ATLConversationViewController!, attributedStringForDisplayOfDate date: NSDate!) -> NSAttributedString! {
        return Formatters.attributedStringForDate(date)
    }
    
    public func conversationViewController(conversationViewController: ATLConversationViewController!, attributedStringForDisplayOfRecipientStatus recipientStatus: [NSObject : AnyObject]!) -> NSAttributedString! {
        return Formatters.attributedStringForDisplayOfRecipientStatus(recipientStatus, ctx: MainContext)
    }
    
}

