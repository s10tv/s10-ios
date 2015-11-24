//
//  AppDelegate.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/24/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import CocoaLumberjack
import Branch
import FBSDKCoreKit
import NKRecorder

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate /* CrashlyticsDelegate, */ {

    var window: UIWindow?
    
    let dependencies = AppDependencies()
    
    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        Analytics.track("AppOpen")
        DDLogInfo("App Will Launch")
        return true
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = RootViewController(bridge: self.dependencies.bridge)
        self.window?.makeKeyAndVisible()
        
        dependencies.branch.initSessionWithLaunchOptions(launchOptions) { params, error in
            DDLogInfo("Initialized branch session params=\(params) error=\(error)")
            self.rnSendAppEvent(.BranchInitialized, body: params)
        }
        AppHub.buildManager().fetchBuildWithCompletionHandler { build, error in
            DDLogInfo("Fetched new build from app hub id=\(build.identifier) name=\(build.name) desc=\(build.buildDescription) date=\(build.creationDate)")
//            for version in build.compatibleIOSVersions { // Crashes right now...
//                DDLogDebug("\(build.name): Compat Version - \(version)")
//            }
        }
        application.registerForRemoteNotifications()
    
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        // Pre-heat the camera if we can
        VideoMakerViewController.preloadRecorderAsynchronously()
        DDLogInfo("App Did Launch")
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

    // MARK: - Push Handling
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        DDLogInfo("Did register user notification settings \(notificationSettings)")
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        DDLogInfo("Registered for push \(deviceToken)")
        if let apsEnv = dependencies.env.apsEnvironment?.rawValue {
            // TODO: Handle push notification registration in JS
            rnSendAppEvent(.RegisteredPushToken, body: [
                "apsEnv": apsEnv,
                "deviceToken": deviceToken.hexString()
            ])
            Analytics.setUserProperties(["RegisteredPush": true])
        } else if !dependencies.env.isRunningInSimulator {
            DDLogError("Non-simulator build should have valid APS environment")
            // fatalError("Non-simulator build should have valid APS environment")
        }
        do {
            try dependencies.layer.layerClient.updateRemoteNotificationDeviceToken(deviceToken)
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
        // This is needed to handle remote notification while app is in the background
        // and therefore didFinishLaunching is never invoked.
        // TODO: LayerClient cannot be recreated, need to do again
        let handled = dependencies.layer.layerClient.synchronizeWithRemoteNotification(userInfo) { changes, error in
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
        dependencies.layer.layerClient.handleBackgroundContentTransfersForSession(identifier) { changes, error in
            if let error = error {
                DDLogError("Failed to handle layer background transfer \(error)")
            } else {
                DDLogInfo("Handled layer background transfer with \(changes?.count) changes")
            }
            completionHandler()
        }
    }
}
