//
//  ConversationListViewManager.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import UIKit
import LayerKit
import React

@objc(TSConversationListViewManager)
class ConversationListViewManager : ViewControllerManager {
    let layerClient: LYRClient
    
    init(layerClient: LYRClient) {
        self.layerClient = layerClient
    }
    
    override func viewWithProps(props: [NSObject : AnyObject]!) -> UIView! {
        guard let currentUser = RCTConvert.userViewModel(props["currentUser"]) else {
            return nil
        }
        let vc = UIStoryboard(name: "Conversation", bundle: nil).instantiateViewControllerWithIdentifier("ConversationList") as! ConversationListViewController
        vc.vm = ConversationListViewModel(layerClient: layerClient, currentUser: currentUser)
        let view = vc.view as! ConversationListView
        view.tsViewController = vc
        view.currentUser = currentUser
        return view
    }
}

class ConversationListView : UITableView {
    var currentUser: UserViewModel!
}
