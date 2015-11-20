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
}

// MARK: - BridgeManager JS API

enum NativeAppEvent : String {
    case RegisteredPushToken = "RegisteredPushToken"
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
