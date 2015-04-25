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
import SwiftyUserDefaults

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
        Log.setUserId(UD[.sMeteorUserId].string)
        Log.setUserName(UD[.sUserDisplayName].string)
        Log.setUserEmail(UD[.sUserEmail].string)
        Crashlytics.sharedInstance().setObjectValue(env.deviceId, forKey: "DeviceId")
        
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
        // HACK ALERT: Adding 0.1 second delay because for some reason when subscriptions are ready
        // the value in the collections are not ready yet. Really need to figure out what the right timing
        // is and get rid of these nasty 0.1 second delay hacks, but for 0.1.0 release it fixes the issue
        Meteor.subscriptions.currentUser.signal.delay(0.1).deliverOnMainThread().subscribeCompleted {
            UD[.sMeteorUserId] ?= Meteor.userID
            UD[.sUserDisplayName] = User.currentUser()?.displayName
            Log.setUserId(UD[.sMeteorUserId].string)
            Log.setUserName(UD[.sUserDisplayName].string)
        }
        Meteor.subscriptions.settings.signal.delay(0.1).deliverOnMainThread().subscribeCompleted {
            UD[.sUserEmail] = Meteor.settings.email
            Log.setUserEmail(UD[.sUserEmail].string)
        }
        Meteor.subscriptions.metadata.signal.delay(0.1).deliverOnMainThread().subscribeCompleted {
            Globals.upgradeService.promptForUpgradeIfNeeded()
        }
        // Should be probably extracted into push service
        application.registerForRemoteNotifications()
        
        // Let's launch!
        Meteor.startup()
        
        Log.info("App Launched")
        Analytics.track("App Open")
        return true
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        SugarRecord.applicationWillEnterForeground()
        Analytics.track("App Open")
        Globals.upgradeService.promptForUpgradeIfNeeded()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        Analytics.track("App Close")
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
            Meteor.updateDevicePush(apsEnv, pushToken: deviceToken.hexString() as String)
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
