//
//  BridgeManager.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import CocoaLumberjack
import React

private let kRNSendAppEventNotificationName = "rnSendAppEvent"

extension NSObject {
    func rnSendAppEvent(name: NativeAppEvent, body: AnyObject?) {
        var userInfo: [String: AnyObject] = ["name": name.rawValue]
        userInfo["body"] = body
        NSNotificationCenter.defaultCenter()
            .postNotificationName(kRNSendAppEventNotificationName, object: self, userInfo: userInfo)
    }
}

@objc(TSBridgeManager)
class BridgeManager : NSObject {
    
    weak var bridge: RCTBridge?
    
    override init() {
        super.init()
        listenForNotification(kRNSendAppEventNotificationName).startWithNext { [weak self] note in
            if let dispatcher = self?.bridge?.eventDispatcher,
                let name = note.userInfo?["name"] as? String {
                    let body = note.userInfo?["body"]
                    DDLogInfo("Will send AppEvent \(name) body=\(body)")
                    dispatcher.sendAppEventWithName(name, body: body)
            }
        }
    }
    
    func viewControllerWithTag(reactTag: Int, block: (UIView, UIViewController) -> ()) {
        if let bridge = bridge {
            dispatch_async(bridge.uiManager.methodQueue) {
                bridge.uiManager.addUIBlock { _, registry in
                    if let view = registry[reactTag] as? UIView, let vc = view.tsViewController {
                        block(view, vc)
                    }
                }
            }
        }
    }
}

// UIView + NativeView

private var kTSViewController: UInt8 = 0

extension UIView {
    var tsViewController: UIViewController? {
        get { return objc_getAssociatedObject(self, &kTSViewController) as? UIViewController }
        set { objc_setAssociatedObject(self, &kTSViewController, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

// MARK: - BridgeManager JS API

enum NativeAppEvent : String {
    case NavigationPush = "Navigation.push"
    case NavigationPop = "Navigation.pop"
}

enum RouteId : String {
    case Profile = "profile"
    case Conversation = "conversation"
}

extension UIViewController {
    func rnNavigationPush(routeId: RouteId, args: [String: AnyObject]) {
        rnSendAppEvent(.NavigationPush, body: ["routeId": routeId.rawValue, "args": args])
    }
    
    func rnNavigationPop() {
        rnSendAppEvent(.NavigationPop, body: nil)
    }
}

extension BridgeManager {
    
    @objc func componentWillMount(reactTag: Int) {
// At this point we can't find view by reactTag just yet...
//        viewControllerWithTag(reactTag) { vc in
//            vc.beginAppearanceTransition(true, animated: false)
//        }
    }
    
    @objc func componentDidMount(reactTag: Int) {
        viewControllerWithTag(reactTag) { view, vc in
            DDLogDebug("\(vc) componentDidMount")
//            vc.beginAppearanceTransition(true, animated: false)
            view.reactAddControllerToClosestParent(vc)
//            if let rootVC = UIApplication.sharedApplication().delegate?.window??.rootViewController {
//                rootVC.addChildViewController(vc)
//                vc.didMoveToParentViewController(rootVC)
//            }
//            assert(vc.parentViewController != nil)
//            vc.endAppearanceTransition()
        }
    }
    
    @objc func componentWillUnmount(reactTag: Int) {
        viewControllerWithTag(reactTag) { view, vc in
            DDLogDebug("\(vc) componentWillUnmount")
//            vc.beginAppearanceTransition(false, animated: false)
            vc.willMoveToParentViewController(nil)
            vc.removeFromParentViewController()
//            vc.endAppearanceTransition()
        }
    }
}
