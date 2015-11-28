//
//  ConversationListViewManager.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import UIKit
import CocoaLumberjack
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
        view.vc = vc
        view.currentUser = currentUser
        return view
    }
}

class ConversationListView : UITableView {
    var currentUser: UserViewModel!
    
    weak var vc: ConversationListViewController?
    
    deinit {
        DDLogVerbose("deinit")
    }
    
    override func willMoveToWindow(newWindow: UIWindow?) {
        super.willMoveToWindow(newWindow)
        guard let vc = vc where vc.presentedViewController == nil else {
            return
        }
        if let parent = newWindow?.rootViewController {
            parent.addChildViewController(vc)
        } else {
            vc.willMoveToParentViewController(nil)
        }
        DDLogVerbose("willMoveToWindow \(newWindow) \(vc.parentViewController)")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard let vc = vc where vc.presentedViewController == nil else {
            return
        }
        if let parent = window?.rootViewController {
            vc.didMoveToParentViewController(parent)
        } else {
            vc.removeFromParentViewController()
        }
        DDLogVerbose("didMoveToWindow \(window) \(vc.parentViewController)")
    }
}
