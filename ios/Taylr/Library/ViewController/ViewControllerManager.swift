//
//  ViewController.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import CocoaLumberjack
import React

@objc(TSViewController)
class ViewControllerManager : RCTViewManager {
    
    func viewControllerWithTag(reactTag: Int, block: (UIView, UIViewController) -> ()) {
        bridge?.uiManager.addUIBlock { _, registry in
            if let view = registry[reactTag] as? UIView, let vc = view.tsViewController {
                block(view, vc)
            }
        }
    }
    
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
    
    func pushRoute(route: String, properties: [String: AnyObject]) {
        var body = properties
        body["route"] = route
        bridge?.eventDispatcher.sendAppEventWithName("ViewController.pushRoute", body: body)
    }
}

// MARK: UIView + NativeView

private var kTSViewController: UInt8 = 0

extension UIView {
    var tsViewController: UIViewController? {
        get { return objc_getAssociatedObject(self, &kTSViewController) as? UIViewController }
        set { objc_setAssociatedObject(self, &kTSViewController, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}