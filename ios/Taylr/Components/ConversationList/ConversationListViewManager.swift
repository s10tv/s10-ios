//
//  ConversationListViewManager.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import LayerKit

@objc(TSConversationListViewManager)
class ConversationListViewManager : ViewControllerManager {
    let layerClient: LYRClient
    var currentUser: UserViewModel?
    
    init(layerClient: LYRClient) {
        self.layerClient = layerClient
    }
    
    override func view() -> UIView! {
        let vc = UIStoryboard(name: "Conversation", bundle: nil).instantiateViewControllerWithIdentifier("ConversationList") as! ConversationListViewController
        vc.vm = ConversationListViewModel(layerClient: layerClient, currentUser: currentUser)
        vc.view.tsViewController = vc
        return vc.view
    }
}
