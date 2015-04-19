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

// Globally accessible variables and shorthands
private struct _GlobalsContainer {
    static var instance: GlobalsContainer!
}
let Globals = _GlobalsContainer.instance

// Shorthand services because they are used all over the place
let Meteor = Globals.meteorService
let Analytics = Globals.analyticsService

let AppDidRegisterUserNotificationSettings = "AppDidRegisterUserNotificationSettings"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CrashlyticsDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Configure the environment
        let env = Environment.configureFromEmbeddedProvisioningProfile()
        
        // Start crash reporting and logging as soon as we can
        Crashlytics.startWithAPIKey(env.crashlyticsAPIKey)
        Crashlytics.sharedInstance().delegate = self
        Bugfender.activateLogger(env.bugfenderAppToken)
        
        // Setup global services
        let meteor = MeteorService(env: env)
        _GlobalsContainer.instance = GlobalsContainer(env: env,
            meteorService: meteor,
            flowService: FlowService(meteorService: meteor),
            accountService: AccountService(meteorService: meteor),
            analyticsService: AnalyticsService(env: env),
            upgradeService: UpgradeService(env: env, settings: meteor.settings),
            locationService: LocationService(meteorService: meteor))

        // Startup the services
        Meteor.meta.bugfenderId = Bugfender.deviceIdentifier()
        Meteor.subscriptions.currentUser.signal.deliverOnMainThread().subscribeCompleted {
            Log.setUserId(Meteor.userID)
            Log.setUserName(User.currentUser()?.displayName)
            Log.setUserEmail(Meteor.settings.email)
            // TODO: Figure out why this hack is needed
            if let userId = Meteor.userID {
                Analytics.identifyUser(userId)
            }
        }
        Meteor.subscriptions.metadata.signal.deliverOnMainThread().subscribeCompleted {
            Globals.upgradeService.promptForUpgradeIfNeeded()
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
        Globals.upgradeService.promptForUpgradeIfNeeded()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        Analytics.appClose()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBAppCall.handleDidBecomeActive()
        application.applicationIconBadgeNumber = 0 // Clear notification first
        application.applicationIconBadgeNumber = Connection.unread().count()
        Globals.locationService.updateLatestLocationIfAvailable()
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
        if let apsEnv = Globals.env.provisioningProfile?.apsEnvironment?.rawValue {
            Meteor.updateDevicePush(apsEnv, pushToken: deviceToken.hexString())
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
