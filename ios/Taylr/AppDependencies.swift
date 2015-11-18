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

class AppDependencies : NSObject {
    let env: Environment
    let config: AppConfig
    let logger: Logger
    
    // Lazily initialized modules
    lazy private(set) var bridge: RCTBridge = {
        return RCTBridge(delegate: self, launchOptions: nil)
    }()
    lazy private(set) var analytics: AnalyticsService = {
        return AnalyticsService(config: self.config, env: self.env)
    }()
    lazy private(set) var layer: LayerService = {
        return LayerService(layerAppID: self.config.layerURL, existingClient: nil)
    }()
    
    override init() {
        env = Environment()
        config = AppConfig(env: env)
        logger = Logger(config: config)
        
        super.init()
        Crashlytics.sharedInstance().delegate = self
        Fabric.with([Digits(), Crashlytics()])
        Appearance.setupGlobalAppearances()
    }
}

extension AppDependencies : RCTBridgeDelegate {
    
    func sourceURLForBridge(bridge: RCTBridge!) -> NSURL! {
        return NSURL("http://localhost:8081/index.ios.bundle?platform=ios&dev=true")
    }
    
    func extraModulesForBridge(bridge: RCTBridge!) -> [AnyObject]! {
        return [
            ConversationListViewManager(layerClient: layer.layerClient),
            ConversationViewManager(layerClient: layer.layerClient),
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