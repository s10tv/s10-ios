//
//  ConversationViewManager.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import UIKit
import CocoaLumberjack
import LayerKit
import React

@objc(TSConversationViewManager)
class ConversationViewManager : RCTViewManager {
    let sb = UIStoryboard(name: "Conversation", bundle: nil)
    let layer: LayerService
    let session: Session
    
    init(layer: LayerService, session: Session) {
        self.layer = layer
        self.session = session
    }
    
    // TODO: Derive currentUser from session
    override func viewWithProps(props: [NSObject : AnyObject]!) -> UIView! {
        guard let currentUser = RCTConvert.userViewModel(props["currentUser"]) else {
            assertionFailure("currentUser must exist when initializing ConversationView")
            DDLogError("currentUser must exist when initializing ConversationView")
            return nil
        }
        let conversationId: String? = RCTConvert.NSString(props["conversationId"])
        let recipientUser: UserViewModel? = RCTConvert.userViewModel(props["recipientUser"])
        var conv: LYRConversation?
        if let cid = conversationId {
            conv = layer.findConversation(cid)
        } else if let recipientUser = recipientUser {
            do {
                try conv = layer.getOrCreateConversation([currentUser, recipientUser])
            } catch let error as NSError {
                DDLogError("Unable to getOrCreateConversation for user \(recipientUser.userId)", tag: error)
            }
        }
        guard let conversation = conv else {
            assertionFailure("conversation must exist before rendering ConversationView")
            return nil
        }
        
        let vc = sb.instantiateInitialViewController() as! ConversationViewController
        vc.vm = ConversationViewModel(layer: layer, currentUserId: currentUser.userId, conversation: conversation)
        let view = vc.view as! ConversationView
        view.currentUser = currentUser
        view.conversationId = conversationId
        view.recipientUser = recipientUser
        view.vc = vc
        return view
    }
}

class ConversationView : UIView {
    var currentUser: UserViewModel!
    var conversationId: String?
    var recipientUser: UserViewModel?
    
    weak var vc: ConversationViewController?
    
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
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        if let _ = superview {
            translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let superview = superview {
            makeEdgesEqualTo(superview)
        }
    }
}