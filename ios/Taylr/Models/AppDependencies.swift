//
//  AppDependencies.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import CocoaLumberjack
import React
import Fabric
import DigitsKit
import Crashlytics
import LayerKit
import Branch

class AppDependencies : NSObject {
    let env: Environment
    let config: AppConfig
    let branch: Branch
    let amplitude: AmplitudeProvider
    let mixpanel: MixpanelProvider
    let intercom: IntercomProvider
    let segment: SegmentProvider
    let uxcam: UXCamProvider
    
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
        
        // Setup Logging
        Logger.addLogger(DDTTYLogger.sharedInstance()) // TTY = Xcode console
        Logger.addLogger(DDASLLogger.sharedInstance()) // ASL = Apple System Logs
        Logger.addLogger(DDOuralabsLogger(apiKey: config.ouralabsKey))
        Logger.addLogger(DDNSLogger())
        
        // Setup Analytics
        branch = Branch.getInstance(config.branchKey)
        amplitude = AmplitudeProvider(apiKey: config.amplitudeKey)
        mixpanel = MixpanelProvider(apiToken: config.mixpanelToken, launchOptions: nil) // TODO: Add launchOptions
        intercom = IntercomProvider(appId: config.intercom.appId, apiKey: config.intercom.apiKey)
        segment = SegmentProvider(writeKey: config.segmentWriteKey)
        uxcam = UXCamProvider(apiKey: config.uxcamKey)
        Analytics.providers = [amplitude, mixpanel, intercom, segment, uxcam]
        
        super.init()
        Crashlytics.sharedInstance().delegate = self
        Fabric.with([Digits(), Crashlytics()])
        AppHub.setApplicationID(config.appHubApplicationId)
        AppHub.buildManager().cellularDownloadsEnabled = true
        switch config.audience {
        case .AppStore:
            AppHub.buildManager().debugBuildsEnabled = false
        default:
            AppHub.buildManager().debugBuildsEnabled = true
        }
    }
}

extension AppDependencies : RCTBridgeDelegate {
    
    func sourceURLForBridge(bridge: RCTBridge!) -> NSURL! {
        // Tony's Computer, uncomment for live, on-device development
//        return NSURL("http://192.168.0.252:8081/index.ios.bundle?platform=ios&dev=true")
        if env.isRunningInSimulator {
            return NSURL("http://localhost:8081/index.ios.bundle?platform=ios&dev=true")
        } else if env.build == "0" {
            return NSBundle.mainBundle().URLForResource("main", withExtension: "jsbundle")
        } else {
            let build = AppHub.buildManager().currentBuild
            return build.bundle.URLForResource("main", withExtension: "jsbundle")
        }
    }
    
    func extraModulesForBridge(bridge: RCTBridge!) -> [AnyObject]! {
        return [
            ConversationListViewManager(layer: layer),
            ConversationViewManager(layer: layer),
            Analytics,
            Logger,
            layer,
            intercom,
        ]
    }
}

extension AppDependencies : CrashlyticsDelegate {
    func crashlyticsDidDetectReportForLastExecution(report: CLSReport, completionHandler: (Bool) -> Void) {
        // Log crash to analytics & logging
        completionHandler(true)
    }
}