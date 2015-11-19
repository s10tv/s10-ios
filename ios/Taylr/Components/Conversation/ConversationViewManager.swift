//
//  ConversationViewManager.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import LayerKit

@objc(TSConversationViewManager)
class ConversationViewManager : ViewControllerManager {
    let layerClient: LYRClient
    
    init(layerClient: LYRClient) {
        self.layerClient = layerClient
    }
    
    override func view() -> UIView! {
        let vc = UIStoryboard(name: "Conversation", bundle: nil).instantiateViewControllerWithIdentifier("Conversation") as! ConversationViewController
        vc.layerClient = layerClient
        let view = vc.view as! ConversationView
        view.vc = vc
        return view
    }
}

class ConversationView : UIView {
    var vc: ConversationViewController!
    
    var userId: String?
    
}