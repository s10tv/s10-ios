//
//  AppDelegate.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/24/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import CocoaLumberjack
import React
import Branch
import FBSDKCoreKit
import NKRecorder
import Fabric
import DigitsKit
import Crashlytics
import LayerKit
import Branch

@UIApplicationMain
class AppDelegate : UIResponder {
    var window: UIWindow?
    
    var env: Environment!
    var config: AppConfig!
    var ouralabs: DDOuralabsLogger!
    var branch: BranchProvider!
    var amplitude: AmplitudeProvider!
    var mixpanel: MixpanelProvider!
    var intercom: IntercomProvider!
    var segment: SegmentProvider!
    var uxcam: UXCamProvider!
    var layer: LayerService!
    var bridge: RCTBridge!
    var appHubBuild: AHBuildManager!
    
    func setupDependencies(launchOptions: [NSObject: AnyObject]?) {
        Crashlytics.sharedInstance().delegate = self
        Fabric.with([Digits(), Crashlytics()])
        
        env = Environment()
        config = AppConfig(env: env)
        
        // Setup Logging
        ouralabs = DDOuralabsLogger(apiKey: config.ouralabsKey)
        Logger.addLogger(DDTTYLogger.sharedInstance()) // TTY = Xcode console
        Logger.addLogger(DDASLLogger.sharedInstance()) // ASL = Apple System Logs
        Logger.addLogger(ouralabs)
        #if Debug
        Logger.addLogger(DDNSLogger())
        #endif
        
        // Setup Analytics
        branch = BranchProvider(branchKey: config.branchKey)
        amplitude = AmplitudeProvider(apiKey: config.amplitudeKey)
        mixpanel = MixpanelProvider(apiToken: config.mixpanelToken, launchOptions: launchOptions) // TODO: Add launchOptions
        intercom = IntercomProvider(appId: config.intercom.appId, apiKey: config.intercom.apiKey)
        segment = SegmentProvider(writeKey: config.segmentWriteKey)
        uxcam = UXCamProvider(apiKey: config.uxcamKey)
        Analytics.providers = [branch, amplitude, mixpanel, intercom, segment, uxcam, ouralabs]
        
        // Setup Layer
        layer = LayerService(layerAppID: config.layerURL)
        
        // Over the air app update
        AppHub.setApplicationID(config.appHubApplicationId)
        appHubBuild = AppHub.buildManager()
        appHubBuild.cellularDownloadsEnabled = true
        appHubBuild.debugBuildsEnabled = (config.audience != .AppStore)
        
        // Start React Native App
        bridge = RCTBridge(delegate: self, launchOptions: launchOptions)
        
    }
}

// MARK: - Application Delegate

extension AppDelegate : UIApplicationDelegate {

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        setupDependencies(launchOptions)
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = RootViewController(bridge: bridge)
        window?.makeKeyAndVisible()
        
        branch.branch.initSessionWithLaunchOptions(launchOptions) { params, error in
            DDLogInfo("Initialized branch session params=\(params) error=\(error)")
            self.rnSendAppEvent(.BranchInitialized, body: params)
        }
        appHubBuild.fetchBuildWithCompletionHandler { build, error in
            DDLogInfo("Fetched new build from app hub id=\(build.identifier) name=\(build.name) desc=\(build.buildDescription) date=\(build.creationDate)")
//            for version in build.compatibleIOSVersions { // Crashes right now...
//                DDLogDebug("\(build.name): Compat Version - \(version)")
//            }
        }
        application.registerForRemoteNotifications()
    
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        // Pre-heat the camera if we can
        VideoMakerViewController.preloadRecorderAsynchronously()
        DDLogInfo("App Launched", tag: ["deviceId": env.deviceId, "deviceName": env.deviceName])
        return true
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        Analytics.track("AppOpen")
    }

    func applicationDidEnterBackground(application: UIApplication) {
        Analytics.track("AppClose")
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        application.applicationIconBadgeNumber = 0 // Clear notification first
        FBSDKAppEvents.activateApp()
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    // MARK: Push Handling
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        DDLogInfo("Did register user notification settings \(notificationSettings)")
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        DDLogInfo("Registered for push \(deviceToken)")
        if let apsEnv = env.apsEnvironment?.rawValue {
            // TODO: Handle push notification registration in JS
            rnSendAppEvent(.RegisteredPushToken, body: [
                "apsEnv": apsEnv,
                "deviceToken": deviceToken.hexString()
            ])
            Analytics.setUserProperties(["RegisteredPush": true])
        } else if !env.isRunningInSimulator {
            DDLogError("Non-simulator build should have valid APS environment")
            // fatalError("Non-simulator build should have valid APS environment")
        }
        do {
            try layer.layerClient.updateRemoteNotificationDeviceToken(deviceToken)
        } catch let error as NSError {
            DDLogError("Unable to update Layer with push token \(error)")
        }
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        DDLogWarn("Faild to register for push \(error)")
        Analytics.setUserProperties(["RegisteredPush": false])
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        DDLogDebug("Did receive notification \(userInfo)")
        assert(layer != nil)
        let handled = layer.layerClient.synchronizeWithRemoteNotification(userInfo) { changes, error in
            if let error = error {
                DDLogError("Failed to synchronize remote notification with layer \(error)")
                completionHandler(.Failed)
            } else {
                let changes = changes ?? []
                DDLogInfo("Synchronized layer remote notification with \(changes.count) changes")
                if changes.count > 0 {
                    completionHandler(.NewData)
                } else {
                    completionHandler(.NoData)
                }
            }
        }
        if !handled {
            completionHandler(.NoData)
        }
    }

    // MARK: - Background Transfer
    
    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        layer.layerClient.handleBackgroundContentTransfersForSession(identifier) { changes, error in
            if let error = error {
                DDLogError("Failed to handle layer background transfer \(error)")
            } else {
                DDLogInfo("Handled layer background transfer with \(changes?.count) changes")
            }
            completionHandler()
        }
    }
}

// MARK: - RCTBridgeDelegate

extension AppDelegate : RCTBridgeDelegate {
    
    func sourceURLForBridge(bridge: RCTBridge!) -> NSURL! {
        // Tony's Computer, uncomment for live, on-device development
        //        return NSURL("http://192.168.0.252:8081/index.ios.bundle?platform=ios&dev=true")
        if env.isRunningInSimulator {
            return NSURL("http://localhost:8081/index.ios.bundle?platform=ios&dev=true")
        } else if env.build == "0" {
            return NSBundle.mainBundle().URLForResource("main", withExtension: "jsbundle")
        } else {
            let build = appHubBuild.currentBuild
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

// MARK: - Crashlytics Delegate

extension AppDelegate : CrashlyticsDelegate {
    func crashlyticsDidDetectReportForLastExecution(report: CLSReport, completionHandler: (Bool) -> Void) {
        // Log crash to analytics & logging
        completionHandler(true)
    }
}
