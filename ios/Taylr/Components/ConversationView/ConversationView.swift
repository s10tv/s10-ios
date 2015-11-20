//
//  ConversationViewManager.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import UIKit
import CocoaLumberjack
import LayerKit
import React

@objc(TSConversationViewManager)
class ConversationViewManager : RCTViewManager {
    let sb = UIStoryboard(name: "Conversation", bundle: nil)
    let layer: LayerService
    
    init(layer: LayerService) {
        self.layer = layer
    }
    
    override func viewWithProps(props: [NSObject : AnyObject]!) -> UIView! {
        guard let currentUser = RCTConvert.userViewModel(props["currentUser"]) else {
            return nil
        }
        let conversationId: String? = RCTConvert.NSString(props["conversationId"])
        let recipientUser: UserViewModel? = RCTConvert.userViewModel(props["recipientUser"])
        var conv: LYRConversation?
        if let cid = conversationId {
            conv = layer.findConversation(cid)
        } else if let recipientUser = recipientUser {
            do {
                try conv = layer.getOrCreateConversation([currentUser, recipientUser])
            } catch let error as NSError {
                DDLogError("Unable to getOrCreateConversation for user \(recipientUser) error=\(error)")
            }
        }
        guard let conversation = conv else {
            return nil
        }
        
        let vc = sb.instantiateInitialViewController() as! ConversationViewController
        vc.vm = ConversationViewModel(layer: layer, currentUser: currentUser, conversation: conversation)
        let view = vc.view as! ConversationView
        view.tsViewController = vc
        view.currentUser = currentUser
        view.conversationId = conversationId
        view.recipientUser = recipientUser
        return view
    }
}

class ConversationView : UIView {
    var currentUser: UserViewModel!
    var conversationId: String?
    var recipientUser: UserViewModel?
}