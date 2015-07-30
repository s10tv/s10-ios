//
//  AppDelegate.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/24/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Meteor
import SugarRecord
import SwiftyUserDefaults
import Fabric
import DigitsKit
import Crashlytics
import Ouralabs
import RealmSwift
import Core

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
class AppDelegate: UIResponder, UIApplicationDelegate /* CrashlyticsDelegate, */ {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Configure the environment
        let env = TaylrEnvironment.configureFromEmbeddedProvisioningProfile()
        // Initialize Ouralabs before Crashlytics so crashlytics handler
        // so Crashlytics handler does not get overwritten
        Ouralabs.initWithKey(env.ouralabsKey)
        Fabric.with([Digits(), Crashlytics()])
        
        Log.callback = { msg, level in
            Ouralabs.log(.Info, tag: "Test", message: msg, kvp: nil)
        }
        
        // Start crash reporting and logging as soon as we can
//        Bugfender.activateLogger(env.bugfenderAppToken)
        Log.setUserId(UD[.sMeteorUserId].string)
        Log.setUserName(UD[.sUserDisplayName].string)
        Log.setUserEmail(UD[.sUserEmail].string)
//        Crashlytics.sharedInstance().setObjectValue(env.deviceId, forKey: "DeviceId")
        
        // Migrate db if needed
        setDefaultRealmSchemaVersion(3) { migration, oldSchemaVersion in
            // Automatic migration
        }
        
        // Setup global services
        let meteor = MeteorService(serverURL: env.serverURL)
        let settings = Settings(meteor: meteor)
        _GlobalsContainer.instance = GlobalsContainer(env: env,
            meteorService: meteor,
            accountService: AccountService(meteorService: meteor, settings: settings),
            analyticsService: AnalyticsService(env: env),
            upgradeService: UpgradeService(env: env, settings: settings),
            locationService: LocationService(meteorService: meteor),
            taskService: TaskService(meteorService: meteor),
            settings: settings
        )

        // Startup the services

        Meteor.loggedIn.producer
            |> takeWhile { $0 == false }
            |> start(completed: {
                Globals.upgradeService.promptForUpgradeIfNeeded()
            })
        
        SugarRecordLogger.currentLevel = SugarRecordLogger.logLevelError
        
        // Should be probably extracted into push service
        application.registerForRemoteNotifications()
        
        // Let's launch!
        Meteor.startup()
        Meteor.call("connectDevice", env.deviceId, [
            "appId": env.appId,
            "version": env.version,
            "build": env.build
        ])
        
        // Resume unfinished business
        Globals.taskService.resumeUploads()
        Globals.taskService.resumeDownloads()
        Globals.taskService.resumeInvites()
        
        Log.info("App Launched")
        Analytics.track("App Open")
        
        IntegrationsViewController.application(application, didFinishLaunchingWithOptions: launchOptions)
        
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
        application.applicationIconBadgeNumber = 0 // Clear notification first
        Globals.locationService.updateLatestLocationIfAvailable()
    }
    
    func applicationWillResignActive(application: UIApplication) {
        SugarRecord.applicationWillResignActive()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        SugarRecord.applicationWillTerminate()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        if IntegrationsViewController.application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }
        return false
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
//    func crashlytics(crashlytics: Crashlytics!, didDetectCrashDuringPreviousExecution crash: CLSCrashReport!) {
//        Log.error("Crash detected during previous run \(crash)")
//    }
    
}
