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

class UserViewModel : NSObject, ATLParticipant {
    
    let participantIdentifier: String
    let firstName: String
    let lastName: String = "abc"
    let fullName: String = "Tester ABC"
    let avatarImageURL: NSURL? = nil
    let avatarImage: UIImage? = nil
    let avatarInitials: String? = nil
    
    init(participantIdentifier: String) {
        self.participantIdentifier = participantIdentifier
        self.firstName = participantIdentifier
    }
}

class LayerConversationViewController : ATLConversationViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
    }
}

extension LayerConversationViewController : ATLConversationViewControllerDataSource {
    
    func conversationViewController(conversationViewController: ATLConversationViewController!, participantForIdentifier participantIdentifier: String!) -> ATLParticipant! {
        return UserViewModel(participantIdentifier: participantIdentifier)
    }
    
    func conversationViewController(conversationViewController: ATLConversationViewController!, attributedStringForDisplayOfDate date: NSDate!) -> NSAttributedString! {
        return NSAttributedString(string: "Date")
    }
    
    func conversationViewController(conversationViewController: ATLConversationViewController!, attributedStringForDisplayOfRecipientStatus recipientStatus: [NSObject : AnyObject]!) -> NSAttributedString! {
        return NSAttributedString(string: "Status")
    }
    
}

