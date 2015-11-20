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
    
    init(layer: LayerService) {
        self.layer = layer
    }
    
    override func viewWithProps(props: [NSObject : AnyObject]!) -> UIView! {
        guard let currentUser = RCTConvert.userViewModel(props["currentUser"]) else {
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
                DDLogError("Unable to getOrCreateConversation for user \(recipientUser) error=\(error)")
            }
        }
        guard let conversation = conv else {
            return nil
        }
        
        let vc = sb.instantiateInitialViewController() as! ConversationViewController
        vc.vm = ConversationViewModel(layer: layer, currentUser: currentUser, conversation: conversation)
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
    
//    override var frame: CGRect {
//        get { return super.frame }
//        set {
//            DDLogInfo("Set frame current \(frame) to \(newValue)")
//            super.frame = newValue
//        }
//    }
//    
//    override var bounds: CGRect {
//        get { return super.bounds }
//        set {
//            DDLogInfo("Set bounds current \(bounds) to \(newValue)")
//            super.bounds = newValue
//        }
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        DDLogInfo("My frame is \(frame) bounds \(bounds)")
//    }
//    
    override func willMoveToSuperview(newSuperview: UIView?) {
        if let _ = superview {
//            DDLogInfo("Current translate = \(translatesAutoresizingMaskIntoConstraints)")
            translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let superview = superview {
            makeEdgesEqualTo(superview)
        }
    }
    
    deinit {
        DDLogVerbose("deinit will remove from parent vc \(vc?.parentViewController)")
        vc?.willMoveToParentViewController(nil)
        vc?.removeFromParentViewController()
    }
    
    override func reactBridgeDidFinishTransaction() {
        if let vc = vc where vc.parentViewController == nil {
            reactAddControllerToClosestParent(vc)
            DDLogVerbose("react bridge did finish transation, added vc to parent \(vc.parentViewController)")
        }
    }
}