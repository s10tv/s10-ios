//
//  ConversationViewManager.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import LayerKit
import React

@objc(TSConversationViewManager)
class ConversationViewManager : ViewControllerManager {
    let layerClient: LYRClient
    var currentUser: UserViewModel?
    
    init(layerClient: LYRClient) {
        self.layerClient = layerClient
    }
    
    override func viewWithProps(props: [NSObject : AnyObject]!) -> UIView! {
//        guard let currentUser = RCTConvert.userViewModel(props["currentUser"]) else {
//            return nil
//        }
        return nil
//        let vc = UIStoryboard(name: "Conversation", bundle: nil).instantiateViewControllerWithIdentifier("Conversation") as! ConversationViewController
//        vc.vm = ConversationViewModel(layerClient: layerClient, currentUser: currentUser)
//        vc.view.tsViewController = vc
//        return vc.view
    }
}

