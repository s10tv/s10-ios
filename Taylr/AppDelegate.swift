//
//  AppDelegate.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/24/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import Meteor
import SugarRecord
import SwiftyUserDefaults
import Fabric
import DigitsKit
import Crashlytics
import OAuthSwift
import FBSDKCoreKit
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
class AppDelegate: UIResponder, UIApplicationDelegate,/* CrashlyticsDelegate, */METDDPClientDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Configure the environment
        let env = TaylrEnvironment.configureFromEmbeddedProvisioningProfile()
        Fabric.with([Digits(), Crashlytics()])
        
        // Start crash reporting and logging as soon as we can
//        Bugfender.activateLogger(env.bugfenderAppToken)
        Log.setUserId(UD[.sMeteorUserId].string)
        Log.setUserName(UD[.sUserDisplayName].string)
        Log.setUserEmail(UD[.sUserEmail].string)
//        Crashlytics.sharedInstance().setObjectValue(env.deviceId, forKey: "DeviceId")
        
        // Setup global services
        let meteor = MeteorService(serverURL: env.serverURL)
        _GlobalsContainer.instance = GlobalsContainer(env: env,
            meteorService: meteor,
            accountService: AccountService(meteorService: meteor),
            analyticsService: AnalyticsService(env: env),
            upgradeService: UpgradeService(env: env, settings: meteor.settings),
            locationService: LocationService(meteorService: meteor),
            videoService: VideoService(meteorService: meteor))

        // Startup the services
//        Meteor.meta.bugfenderId = Bugfender.deviceIdentifier()
        // HACK ALERT: Adding 0.1 second delay because for some reason when subscriptions are ready
        // the value in the collections are not ready yet. Really need to figure out what the right timing
        // is and get rid of these nasty 0.1 second delay hacks, but for 0.1.0 release it fixes the issue
        Meteor.subscriptions.userData.signal.delay(0.5).deliverOnMainThread().subscribeCompleted {
            if let currentUser = User.currentUser() {
                UD[.sMeteorUserId] ?= currentUser.documentID!
                UD[.sUserDisplayName] = currentUser.displayName.value
                Log.setUserId(currentUser.documentID!)
                Log.setUserName(currentUser.displayName.value)
            }
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
        Meteor.delegate = self
        Meteor.startup()
        Meteor.connectDevice(env)
        
        // Resume unfinished business
        Globals.videoService.resumeUploads()
        
        Log.info("App Launched")
        Analytics.track("App Open")
        
        FBSDKApplicationDelegate.sharedInstance().application(application,
            didFinishLaunchingWithOptions: launchOptions)
        
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
        if FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }
        if (url.host == Globals.env.oauthCallbackPath) {
            if (url.path!.hasPrefix("/twitter") || url.path!.hasPrefix("/flickr") || url.path!.hasPrefix("/fitbit")
                || url.path!.hasPrefix("/withings") || url.path!.hasPrefix("/linkedin") || url.path!.hasPrefix("/bitbucket")
                || url.path!.hasPrefix("/smugmug") || url.path!.hasPrefix("/intuit") || url.path!.hasPrefix("/zaim")
                || url.path!.hasPrefix("/tumblr")) {
                    OAuth1Swift.handleOpenURL(url)
            }
            if ( url.path!.hasPrefix("/github" ) || url.path!.hasPrefix("/instagram" ) || url.path!.hasPrefix("/foursquare")
                || url.path!.hasPrefix("/dropbox") || url.path!.hasPrefix("/dribbble") || url.path!.hasPrefix("/salesforce")
                || url.path!.hasPrefix("/google") || url.path!.hasPrefix("/linkedin2")) {
                OAuth2Swift.handleOpenURL(url)
            }
        } else {
            // Google provider is the only one with your.bundle.id url schema.
            OAuth2Swift.handleOpenURL(url)
        }
        return true
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
    
    // MARK: Meteor Logging
    
    func client(client: METDDPClient, willSendDDPMessage message: [NSObject : AnyObject]) {
        Log.verbose("DDP > \(message)")
    }
    func client(client: METDDPClient, didReceiveDDPMessage message: [NSObject : AnyObject]) {
        Log.verbose("DDP < \(message)")
    }
}
