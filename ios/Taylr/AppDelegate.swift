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
    var crashlytics: DDCrashlyticsLogger!
    var oneSignal: OneSingalProvider!
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
        crashlytics = DDCrashlyticsLogger(crashlytics: Crashlytics.sharedInstance())
        crashlytics.logFormatter = TagLogFormatter()
        DDTTYLogger.sharedInstance().logFormatter = TagLogFormatter()
        DDASLLogger.sharedInstance().logFormatter = TagLogFormatter()
//        Logger.addLogger(DDTTYLogger.sharedInstance()) // TTY = Xcode console
        Logger.addLogger(DDASLLogger.sharedInstance()) // ASL = Apple System Logs
        Logger.addLogger(ouralabs)
        Logger.addLogger(crashlytics)
        #if Debug
        Logger.addLogger(DDNSLogger())
        #endif
        
        // Setup Analytics
        oneSignal = OneSingalProvider(appId: config.oneSignalAppId, launchOptions: launchOptions)
        branch = BranchProvider(branchKey: config.branchKey)
        amplitude = AmplitudeProvider(apiKey: config.amplitude.apiKey)
        mixpanel = MixpanelProvider(apiToken: config.mixpanel.token, launchOptions: launchOptions)
        intercom = IntercomProvider(config: config)
        segment = SegmentProvider(writeKey: config.segmentWriteKey)
        uxcam = UXCamProvider(apiKey: config.uxcamKey)
        Analytics.addProviders([oneSignal, branch, amplitude, mixpanel, intercom, segment, uxcam, ouralabs, crashlytics])
        
        // Setup Layer
        layer = LayerService(layerAppID: config.layerURL)
        
        // Over the air app update
        AppHub.setApplicationID(config.appHubApplicationId)
        appHubBuild = AppHub.buildManager()
        appHubBuild.cellularDownloadsEnabled = true
        appHubBuild.debugBuildsEnabled = (config.audience != .AppStore)
        
        // TODO: Refactor this lifecycle management stuff outside of Analytics
        // Do not persist meteor user account across app installs, make it harder to test and is unexpected
        // NOTE: Hack alert. we use layer as a proxy to know whether this was an upgrade rather than new install
        if Analytics.isNewInstall && layer.layerClient.authenticatedUserID == nil {
            METAccount.setDefaultAccount(nil)
        }
        
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
        Analytics.appDidLaunch(launchOptions)

        // Pre-heat the camera if we can
        VideoMakerViewController.preloadRecorderAsynchronously()
        DDLogInfo("App Did Launch \(env.deviceName)", tag: ["deviceId": env.deviceId, "deviceName": env.deviceName])
        return true
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        Analytics.appWillEnterForeground()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        Analytics.appDidEnterBackground()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        application.applicationIconBadgeNumber = 0 // Clear notification first
        FBSDKAppEvents.activateApp()
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        branch.branch.handleDeepLink(url)
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    // MARK: Push Handling
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        DDLogInfo("Did register user notification settings \(notificationSettings)")
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        DDLogInfo("Registered for push \(deviceToken)")
        Analytics.appDidRegisterForPushToken(deviceToken)
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
        Analytics.appDidReceivePushNotification(userInfo)
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
            BridgeManager(env: env, config: config),
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
