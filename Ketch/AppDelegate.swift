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
import BugfenderSDK

private struct Globals {
    static var environment : Environment!
    static var meteorService : MeteorService!
    static var flowService : FlowService!
    static var accountService : AccountService!
    static var analyticsService : AnalyticsService!
}

let Env = Globals.environment
let Meteor = Globals.meteorService
let Flow = Globals.flowService
let Account = Globals.accountService
let Analytics = Globals.analyticsService
let NC = NSNotificationCenter.defaultCenter()
let UD = NSUserDefaults.standardUserDefaults()

let AppDidRegisterUserNotificationSettings = "AppDidRegisterUserNotificationSettings"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CrashlyticsDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Configure the environment
        Globals.environment = Environment.configureFromEmbeddedProvisioningProfile()
        
        // Start crash reporting and logging as soon as we can
        Crashlytics.startWithAPIKey(Env.crashlyticsAPIKey)
        Crashlytics.sharedInstance().delegate = self
        Bugfender.activateLogger(Env.bugfenderAppToken)
        
        // Setup global services
        Globals.meteorService = MeteorService(serverURL: Env.serverURL)
        Globals.accountService = AccountService(meteorService: Meteor)
        Globals.flowService = FlowService(meteorService: Meteor)
        Globals.analyticsService = AnalyticsService(env: Env)
        
        Meteor.meta.bugfenderId = Bugfender.deviceIdentifier()
        Meteor.subscriptions.currentUser.signal.deliverOnMainThread().subscribeCompleted {
            Log.setUserId(Meteor.userID)
            Log.setUserName(User.currentUser()?.displayName)
            Log.setUserEmail(Meteor.meta.email)
            Analytics.identifyUser(Meteor.userID!)
        }
        
        // Should be probably extracted into push service
        application.registerForRemoteNotifications()
        
        // Let's launch!
        Meteor.startup()
        
        Log.info("App Launched")
        Analytics.appOpen()
        return true
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        SugarRecord.applicationWillEnterForeground()
        Analytics.appOpen()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        Analytics.appClose()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBAppCall.handleDidBecomeActive()
        application.applicationIconBadgeNumber = 0 // Clear notification first
        application.applicationIconBadgeNumber = Connection.unread().count()
    }
    
    func applicationWillResignActive(application: UIApplication) {
        SugarRecord.applicationWillResignActive()
        application.applicationIconBadgeNumber = Connection.unread().count()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        SugarRecord.applicationWillTerminate()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
    }
    
    // MARK: - Push Handling
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        NC.postNotificationName(AppDidRegisterUserNotificationSettings, object: notificationSettings)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Log.info("Registered for push \(deviceToken)")
        if let apsEnv = Env.provisioningProfile?.apsEnvironment?.rawValue {
            Meteor.addPushToken(appID: Env.appID, apsEnv: apsEnv, pushToken: deviceToken)
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        Log.warn("Faild to register for push \(error)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        Log.debug("Did receive notification \(userInfo)")
    }
    
    // MARK: Crashlytics
    func crashlytics(crashlytics: Crashlytics!, didDetectCrashDuringPreviousExecution crash: CLSCrashReport!) {
        Log.error("Crash detected during previous run \(crash)")
    }
}
