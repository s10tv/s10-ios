//
//  ViewController.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import React

@objc(TSViewController)
class ViewControllerManager : RCTViewManager {
    
    func viewControllerWithTag(reactTag: Int, block: (UIViewController) -> ()) {
        bridge?.uiManager.addUIBlock { _, registry in
            if let vc = (registry[reactTag] as? UIView)?.tsViewController {
                block(vc)
            }
        }
    }
    
    @objc func componentWillMount(reactTag: Int) {
        viewControllerWithTag(reactTag) { vc in
            vc.beginAppearanceTransition(true, animated: false)
        }
    }
    
    @objc func componentDidMount(reactTag: Int) {
        viewControllerWithTag(reactTag) { vc in
            vc.endAppearanceTransition()
        }
    }
    
    @objc func componentWillUnmount(reactTag: Int) {
        viewControllerWithTag(reactTag) { vc in
            vc.beginAppearanceTransition(false, animated: false)
        }
    }
    
    @objc func componentDidUnmount(reactTag: Int) {
        viewControllerWithTag(reactTag) { vc in
            vc.endAppearanceTransition()
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