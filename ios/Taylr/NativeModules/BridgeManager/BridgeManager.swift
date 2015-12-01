//
//  BridgeManager.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import CocoaLumberjack
import AppHub
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
    let appHub: AHBuildManager
    
    init(env: Environment, config: AppConfig) {
        self.env = env
        self.config = config
        self.appHub = AppHub.buildManager()
        super.init()
        appHub.cellularDownloadsEnabled = true
        switch config.audience {
        case .Dev, .Beta:
            appHub.debugBuildsEnabled = true
        default:
            appHub.debugBuildsEnabled = false
        }
        listenForNotification(kRNSendAppEventNotificationName).startWithNext { [weak self] note in
            if let bridge = self?.bridge, let name = note.userInfo?["name"] as? String {
                // Sometimes this causes a crash, workaround is to make BridgeManager singleton
                bridge.sendAppEvent(name, body: note.userInfo?["body"])
            }
        }
    }
    
    func pollNewBuild() -> SignalProducer<AHBuild, NSError> {
        return SignalProducer { sink, _ in
            DDLogDebug("Will fetch build from AppHub")
            self.appHub.fetchBuildWithCompletionHandler { build, error in
                if let build = build {
                    DDLogInfo("Did fetch build from AppHub identifier=\(build.identifier) name=\(build.name) " +
                        "desc=\(build.buildDescription) date=\(build.creationDate) compatibleIOSVersions=\(build.compatibleIOSVersions)")
                    sendNextAndCompleted(sink, build)
                } else {
                    DDLogError("Error fetching build from AppHub", tag: error)
                    sendError(sink, error)
                }
            }
        }
    }
}

// MARK: - BridgeManager JS API

extension BridgeManager {
    
    @objc func registerForPushNotifications() {
        // Explicit dependency please, maybe custom module for OneSignal as well
        DDLogInfo("Will register for push notification bridge \(bridge)")
        OneSignal.defaultClient().registerForPushNotifications()
    }
    
    @objc func reloadBridge() {
        DDLogInfo("Will reload bridge \(bridge)")
        bridge?.reload()
    }
    
    @objc func pollNewBuildAsync(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        // For some reason if we use SignalProducer.promise here it breaks build...
        pollNewBuild().map { build in
            build.valueForKey("dictionaryValue") // HACK ALERT: Relying on internal API...
        }.promise(resolve, reject).start()
    }
    
    @objc func setDebugBuildsEnabled(debugBuildsEnabled: Bool) {
        appHub.debugBuildsEnabled = debugBuildsEnabled
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
