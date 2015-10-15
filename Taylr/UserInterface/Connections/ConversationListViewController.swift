//
//  ConversationListViewController.swift
//  S10
//
//  Created by Tony Xiao on 10/14/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import Atlas
import Core

class ConversationListViewController : ATLConversationListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarItem.title = nil
        layerClient = Layer.layerClient
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        layerClient.newConversationWithParticipants(<#T##participants: Set<NSObject>!##Set<NSObject>!#>, options: <#T##[NSObject : AnyObject]!#>)
    }
    
}