//
//  BridgeManager.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import CocoaLumberjack
import ReactiveCocoa
import React

private let kRNSendAppEventNotificationName = "rnSendAppEvent"

enum NativeAppEvent : String {
    case RegisteredPushToken = "RegisteredPushToken"
    case NavigationPush = "Navigation.push"
    case NavigationPop = "Navigation.pop"
    case BranchInitialized = "Branch.initialized"
    case ProfileShowMoreOptions = "Profile.showMoreOptions"
}

extension NSObject {
    func rnSendAppEvent(name: NativeAppEvent, body: AnyObject?) {
        var userInfo: [String: AnyObject] = ["name": name.rawValue]
        userInfo["body"] = body
        NSNotificationCenter.defaultCenter()
            .postNotificationName(kRNSendAppEventNotificationName, object: self, userInfo: userInfo)
    }
}

extension RCTBridge {
    
    func sendAppEvent(name: String, body: AnyObject?) {
        DDLogDebug("Will sendAppEvent name=\(name)", tag: body)
        eventDispatcher.sendAppEventWithName(name, body: body)
    }
}

@objc(TSBridgeManager)
class BridgeManager : NSObject {
    
    weak var bridge: RCTBridge?
    let env: Environment
    let config: AppConfig
    
    init(env: Environment, config: AppConfig) {
        self.env = env
        self.config = config
        super.init()
        listenForNotification(kRNSendAppEventNotificationName).startWithNext { [weak self] note in
            if let bridge = self?.bridge, let name = note.userInfo?["name"] as? String {
                bridge.sendAppEvent(name, body: note.userInfo?["body"])
            }
        }
    }
}

// MARK: - BridgeManager JS API

extension BridgeManager {
    
    @objc func registerForPushNotifications() {
        // Explicit dependency please, maybe custom module for OneSignal as well
        OneSignal.defaultClient().registerForPushNotifications()
    }
    
    @objc func constantsToExport() -> NSDictionary {
        return [
            "isRunningInSimulator": env.isRunningInSimulator,
            "isRunningTestFlightBeta": env.isRunningTestFlightBeta,
            "serverUrl": config.serverURL.absoluteString,
            "bundleUrlScheme": config.audience.urlScheme,
            "audience": config.audience.rawValue,
            "appId": env.appId,
            "version": env.version,
            "build": env.build,
            "deviceId": env.deviceId,
            "deviceName": env.deviceName,
        ]
    }
    
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
