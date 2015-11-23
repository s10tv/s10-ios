//
//  AppDependencies.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import React
import Fabric
import DigitsKit
import Crashlytics
import LayerKit
import Branch

class AppDependencies : NSObject {
    let env: Environment
    let config: AppConfig
    let logger: Logger
    let analytics: Analytics
    let branch: Branch
    
    // Lazily initialized modules
    lazy private(set) var bridge: RCTBridge = {
        return RCTBridge(delegate: self, launchOptions: nil)
    }()

    lazy private(set) var layer: LayerService = {
        return LayerService(layerAppID: self.config.layerURL)
    }()
    
    override init() {
        env = Environment()
        config = AppConfig(env: env)
        logger = Logger(config: config)
        analytics = Analytics(config: config)
        branch = Branch.getInstance(config.branchKey)
        
        super.init()
        Crashlytics.sharedInstance().delegate = self
        Fabric.with([Digits(), Crashlytics()])
        AppHub.setApplicationID(config.appHubApplicationId)
    }
}

extension AppDependencies : RCTBridgeDelegate {
    
    func sourceURLForBridge(bridge: RCTBridge!) -> NSURL! {
        // Tony's Computer, uncomment for live, on-device development
//        return NSURL("http://192.168.0.252:8081/index.ios.bundle?platform=ios&dev=true")
        if env.isRunningInSimulator {
            return NSURL("http://localhost:8081/index.ios.bundle?platform=ios&dev=true")
        } else {
            let build = AppHub.buildManager().currentBuild
            return build.bundle.URLForResource("main", withExtension: "jsbundle")
        }
    }
    
    func extraModulesForBridge(bridge: RCTBridge!) -> [AnyObject]! {
        return [
            ConversationListViewManager(layer: layer),
            ConversationViewManager(layer: layer),
            layer,
            analytics,
            logger,
        ]
    }
}

extension AppDependencies : CrashlyticsDelegate {
    func crashlyticsDidDetectReportForLastExecution(report: CLSReport, completionHandler: (Bool) -> Void) {
        // Log crash to analytics & logging
        completionHandler(true)
    }
}