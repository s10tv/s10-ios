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
        view.strongVC = vc
        view.vc = vc
        view.currentUser = currentUser
        return view
    }
}

class ConversationListView : UITableView {
    var currentUser: UserViewModel!
    
    var strongVC: ConversationListViewController?
    weak var vc: ConversationListViewController?
    
    deinit {
        DDLogVerbose("ConversationListView deinit")
    }
    
    override func willMoveToWindow(newWindow: UIWindow?) {
        super.willMoveToWindow(newWindow)
        if vc?.parentViewController == nil {
            DDLogVerbose("Will move to window \(newWindow)")
//            vc?.viewWillAppear(false)
            vc?.beginAppearanceTransition(newWindow != nil, animated: false)
        }
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        DDLogVerbose("Did move to window \(window)")
        if vc?.parentViewController == nil {
//            vc?.viewDidAppear(false)
            vc?.endAppearanceTransition()
        }
        // viewDidAppear will unfortunately be called twice. But in practice it doesn't seem to harm anything
        // because ConversationListViewController's viewDidAppear is a no-op
        
        if window == nil && superview == nil {
            DDLogVerbose("both window & superview are nil, will remove vc from parent")
            vc?.willMoveToParentViewController(nil)
            vc?.removeFromParentViewController()
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        DDLogVerbose("Did move to superview \(superview)")
        if window == nil && superview == nil {
            DDLogVerbose("both window & superview are nil, will remove vc from parent")
            vc?.willMoveToParentViewController(nil)
            vc?.removeFromParentViewController()
        }
    }
    
    override func reactBridgeDidFinishTransaction() {
        if let vc = strongVC where vc.parentViewController == nil {
            reactAddControllerToClosestParent(vc)
            DDLogVerbose("react bridge did finish transation, added vc to parent \(vc.parentViewController)")
            if vc.parentViewController != nil {
                DDLogVerbose("Will Remove reference to strongVC from view")
                strongVC = nil
            }
        }
    }
}
