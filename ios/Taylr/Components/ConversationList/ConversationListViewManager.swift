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
    
    init(layerClient: LYRClient) {
        self.layerClient = layerClient
    }
    
    override func view() -> UIView! {
        let vc = UIStoryboard(name: "Conversation", bundle: nil).instantiateViewControllerWithIdentifier("Conversation") as! ConversationListViewController
        vc.layerClient = layerClient
        return vc.view
    }
}
