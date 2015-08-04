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
let DidTouchStatusBar = "DidTouchStatusBar"

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
        Log.setUserId(UD.meteorUserId.value)
        Log.setUserName(UD.userDisplayName.value)
        Log.setUserEmail(UD.userEmail.value)
        
//        Crashlytics.sharedInstance().setObjectValue(env.deviceId, forKey: "DeviceId")
        
        // Migrate db if needed
        setDefaultRealmSchemaVersion(5) { migration, oldSchemaVersion in
            // Automatic migration
        }
        
        // Setup global services
        let meteor = MeteorService(serverURL: env.serverURL)
        let settings = Settings(meteor: meteor)
        // WARMING: Startup meteor before initializing accountService
        // so that account.state is initially correct
        meteor.startup()
        
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
        SugarRecordLogger.currentLevel = SugarRecordLogger.logLevelError
        
        // Should be probably extracted into push service
        application.registerForRemoteNotifications()
        
        // Let's launch!
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
        
        Globals.accountService.login()
        Appearance.setupGlobalAppearances()
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = RootNavController(account: Globals.accountService)
        window?.makeKeyAndVisible()
        
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
        let nc = NSNotificationCenter.defaultCenter()
        nc.postNotificationName(AppDidRegisterUserNotificationSettings, object: notificationSettings)
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
    
    // MARK: Event Handling
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        if let touch = event.allTouches()?.first as? UITouch,
            let location = window.map({ touch.locationInView($0) })
            where location.y > 0 && location.y < 20 {
            NSNotificationCenter.defaultCenter().postNotificationName(DidTouchStatusBar, object: nil)
        }    
    }
    
    // MARK: Crashlytics
//    func crashlytics(crashlytics: Crashlytics!, didDetectCrashDuringPreviousExecution crash: CLSCrashReport!) {
//        Log.error("Crash detected during previous run \(crash)")
//    }
    
}
