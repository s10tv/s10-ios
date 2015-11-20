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
class ConversationListViewManager : RCTViewManager {
    let sb = UIStoryboard(name: "ConversationList", bundle: nil)
    let layer: LayerService
    
    init(layer: LayerService) {
        self.layer = layer
    }
    
    override func viewWithProps(props: [NSObject : AnyObject]!) -> UIView! {
        guard let currentUser = RCTConvert.userViewModel(props["currentUser"]) else {
            return nil
        }
        let vc = sb.instantiateInitialViewController() as! ConversationListViewController
        vc.vm = ConversationListViewModel(layerClient: layer.layerClient, currentUser: currentUser)
        let view = vc.view as! ConversationListView
        view.tsViewController = vc
        view.currentUser = currentUser
        return view
    }
}

class ConversationListView : UITableView {
    var currentUser: UserViewModel!
}
