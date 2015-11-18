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
import Ouralabs
import LayerKit

class AppDependencies : NSObject {
    let env: TaylrEnvironment
    
    // Lazily initialized modules
    lazy private(set) var bridge: RCTBridge = {
        return RCTBridge(delegate: self, launchOptions: nil)
    }()
    lazy private(set) var analytics: AnalyticsService = {
        let user = CurrentUser()
        return AnalyticsService(env: self.env, currentUser: user)
    }()
    lazy private(set) var layer: LayerService = {
        return LayerService(layerAppID: self.env.layerURL, existingClient: nil)
    }()
    
    override init() {
        env = TaylrEnvironment.configureFromEmbeddedProvisioningProfile()
        super.init()
        Fabric.with([Digits(), Crashlytics()])
        Crashlytics.sharedInstance().delegate = self
        Ouralabs.initWithKey(env.ouralabsKey)
        Appearance.setupGlobalAppearances()
    }
}

extension AppDependencies : RCTBridgeDelegate {
    
    func sourceURLForBridge(bridge: RCTBridge!) -> NSURL! {
        return NSURL("http://localhost:8081/index.ios.bundle?platform=ios&dev=true")
    }
    
    func extraModulesForBridge(bridge: RCTBridge!) -> [AnyObject]! {
        return []
    }
}

extension AppDependencies : CrashlyticsDelegate {
    func crashlyticsDidDetectReportForLastExecution(report: CLSReport, completionHandler: (Bool) -> Void) {
        // Log crash to analytics & logging
        completionHandler(true)
    }
}