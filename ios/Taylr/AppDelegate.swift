//
//  AppDelegate.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/24/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import CocoaLumberjack
import ARAnalytics
import FBSDKCoreKit
import NKRecorder

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate /* CrashlyticsDelegate, */ {

    var window: UIWindow?
    
    let dependencies = AppDependencies()
    
    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        DDLogInfo("App Launched")
        ARAnalytics.event("AppOpen")
        return true
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = RootViewController(bridge: dependencies.bridge)
        window?.makeKeyAndVisible()
        
        application.registerForRemoteNotifications()
//        Globals.layerService.connectAndKeepUserInSync()
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        // Pre-heat the camera if we can
        VideoMakerViewController.preloadRecorderAsynchronously()
        return true
    }
//    
//    func applicationWillEnterForeground(application: UIApplication) {
//        ARAnalytics.event("AppOpen")
//    }
//    
//    func applicationDidEnterBackground(application: UIApplication) {
//        ARAnalytics.event("AppClose")
//    }
//    
    func applicationDidBecomeActive(application: UIApplication) {
        application.applicationIconBadgeNumber = 0 // Clear notification first
        FBSDKAppEvents.activateApp()
    }
//
//    func applicationWillResignActive(application: UIApplication) {
//        // For some reason this causes a deadlock, so let's not do it
////        SugarRecord.applicationWillResignActive()
//    }
//    
//    func applicationWillTerminate(application: UIApplication) {
////        SugarRecord.applicationWillTerminate()
//    }
//    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
//
//    // MARK: - Push Handling
//    
//    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
//    }
//    
//    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
//        DDLogInfo("Registered for push \(deviceToken)")
//        if let apsEnv = Globals.env.apsEnvironment?.rawValue {
////            MainContext.meteor.updateDevicePush(apsEnv, pushToken: deviceToken.hexString() as String)
//            Analytics.setUserProperties(["RegisteredPush": true])
//        } else if IS_TARGET_IPHONE_SIMULATOR == false {
//            DDLogError("Non-simulator build should have valid APS environment")
//            // fatalError("Non-simulator build should have valid APS environment")
//        }
//        do {
//            try layerClient.updateRemoteNotificationDeviceToken(deviceToken)
//        } catch let error as NSError {
//            DDLogError("Unable to update Layer with push token", error)
//        }
//    }
//    
//    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
//        DDLogWarn("Faild to register for push \(error)")
//        Analytics.setUserProperties(["RegisteredPush": false])
//    }
//    
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
//        DDLogDebug("Did receive notification \(userInfo)")
//        // This is needed to handle remote notification while app is in the background
//        // and therefore didFinishLaunching is never invoked.
//        // TODO: LayerClient cannot be recreated, need to do again
//        if layerClient == nil {
//            let env = TaylrEnvironment.configureFromEmbeddedProvisioningProfile()
//            layerClient = LayerService.defaultLayerClient(env.layerURL)
//        }
//        let handled = layerClient.synchronizeWithRemoteNotification(userInfo) { changes, error in
//            if let error = error {
//                DDLogError("Failed to synchronize remote notification with layer", error)
//                completionHandler(.Failed)
//            } else {
//                let changes = changes ?? []
//                DDLogInfo("Synchronized layer remote notification with \(changes.count) changes")
//                if changes.count > 0 {
//                    completionHandler(.NewData)
//                } else {
//                    completionHandler(.NoData)
//                }
//            }
//        }
//        if !handled {
//            completionHandler(.NoData)
//        }
//    }
//    
//    // MARK: - Background Transfer
//    
//    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
//        // TODO: Better pattern for getting layerClient is needed
//        if layerClient == nil {
//            let env = TaylrEnvironment.configureFromEmbeddedProvisioningProfile()
//            layerClient = LayerService.defaultLayerClient(env.layerURL)
//        }
//        layerClient.handleBackgroundContentTransfersForSession(identifier) { changes, error in
//            if let error = error {
//                DDLogError("Failed to handle layer background transfer", error)
//            } else {
//                DDLogInfo("Handled layer background transfer with \(changes?.count) changes")
//            }
//            completionHandler()
//        }
//    }
}
