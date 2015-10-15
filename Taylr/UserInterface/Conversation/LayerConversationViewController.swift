//
//  LayerConversationViewController.swift
//  S10
//
//  Created by Tony Xiao on 10/14/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import Atlas
import Core

class LayerConversationViewController : ATLConversationViewController {

    var vm: LayerConversationViewModel! {
        didSet { conversation = vm.conversation }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = vm
        
        view.backgroundColor = UIColor(hex: 0xF2F2F6)
    }
}

// MARK: - ATLConversationViewControllerDataSource

extension LayerConversationViewModel : ATLConversationViewControllerDataSource {
    
    public func conversationViewController(conversationViewController: ATLConversationViewController!, participantForIdentifier participantIdentifier: String!) -> ATLParticipant! {
        return recipient()
    }
    
    public func conversationViewController(conversationViewController: ATLConversationViewController!, attributedStringForDisplayOfDate date: NSDate!) -> NSAttributedString! {
        return NSAttributedString(string: "Date")
    }
    
    public func conversationViewController(conversationViewController: ATLConversationViewController!, attributedStringForDisplayOfRecipientStatus recipientStatus: [NSObject : AnyObject]!) -> NSAttributedString! {
        return NSAttributedString(string: "Status")
    }
    
}

