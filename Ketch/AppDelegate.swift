//
//  AppDelegate.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/24/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import SugarRecord
import FacebookSDK
import CrashlyticsFramework

var Core : CoreService!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CrashlyticsDelegate {

    var window: UIWindow?

    var rootVC: RootViewController! {
        get {
            return window?.rootViewController as RootViewController
        }
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // TODO: Put api key into unified settings file
        Crashlytics.sharedInstance().delegate = self
        Crashlytics.startWithAPIKey("4cdb005d0ddfebc8865c0a768de9b43c993e9113")
        Core = CoreService()
        
        Log.info("App Launched")

        let settings = UIUserNotificationSettings(forTypes:
                UIUserNotificationType.Badge |
                UIUserNotificationType.Alert |
                UIUserNotificationType.Sound,
            categories: nil )
        
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        return true
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        SugarRecord.applicationWillEnterForeground()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBAppCall.handleDidBecomeActive()
        application.applicationIconBadgeNumber = 0 // Clear notification first
        application.applicationIconBadgeNumber = Connection.unreadCount()
    }
    
    func applicationWillResignActive(application: UIApplication) {
        SugarRecord.applicationWillResignActive()
        application.applicationIconBadgeNumber = Connection.unreadCount()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        SugarRecord.applicationWillTerminate()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
    }
    
    // MARK: - Push Handling
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        println("Registered for push \(deviceToken)")
        Core.addPushToken(deviceToken)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println("Faild to register for push \(error)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        println("Did receive notification \(userInfo)")
    }
    
    // MARK: Crashlytics
    func crashlytics(crashlytics: Crashlytics!, didDetectCrashDuringPreviousExecution crash: CLSCrashReport!) {
        println("Crash detected during previous run \(crash)")
    }
}
