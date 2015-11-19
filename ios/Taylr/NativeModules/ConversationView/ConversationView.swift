//
//  ConversationViewManager.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import UIKit
import LayerKit
import React

@objc(TSConversationViewManager)
class ConversationViewManager : ViewControllerManager {
    let sb = UIStoryboard(name: "Conversation", bundle: nil)
    let layer: LayerService
    
    init(layer: LayerService) {
        self.layer = layer
    }
    
    override func viewWithProps(props: [NSObject : AnyObject]!) -> UIView! {
        guard let currentUser = RCTConvert.userViewModel(props["currentUser"]),
            let conversationId = RCTConvert.NSString(props["conversationId"]),
            let conversation = layer.findConversation(conversationId) else {
                return nil
        }
        let vc = sb.instantiateInitialViewController() as! ConversationViewController
        vc.vm = ConversationViewModel(layer: layer, currentUser: currentUser, conversation: conversation)
        let view = vc.view as! ConversationView
        view.tsViewController = vc
        view.currentUser = currentUser
        view.conversationId = conversationId
        return view
    }
}

class ConversationView : UIView {
    var currentUser: UserViewModel!
    var conversationId: String!
}