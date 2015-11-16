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
import LayerKit
import SCRecorder
import AVFoundation
import React
import NKRecorder

// Globally accessible variables and shorthands
private struct _GlobalsContainer {
    static var instance: GlobalsContainer!
}
let Globals = _GlobalsContainer.instance

// Shorthand services because they are used all over the place
let MainContext = Context(layer: Globals.layerService)
let Analytics = Globals.analyticsService

let AppDidRegisterUserNotificationSettings = "AppDidRegisterUserNotificationSettings"
let DidTouchStatusBar = "DidTouchStatusBar"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate /* CrashlyticsDelegate, */ {

    var window: UIWindow?
    var layerClient: LYRClient!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Digits(), Crashlytics()])
        
        // Configure the environment
        let env = TaylrEnvironment.configureFromEmbeddedProvisioningProfile()
        // Initialize Ouralabs before Crashlytics so crashlytics handler
        // so Crashlytics handler does not get overwritten
        Ouralabs.initWithKey(env.ouralabsKey)
        Log.callback = { msg, level in
            Ouralabs.log(.Info, tag: "Test", message: msg, kvp: nil)
        }
        
        // Start crash reporting and logging as soon as we can
        Log.setUserId(UD.meteorUserId.value)
        Log.setUserName(UD.userDisplayName.value)
        Log.setUserEmail(UD.userEmail.value)
        
//        Crashlytics.sharedInstance().setObjectValue(env.deviceId, forKey: "DeviceId")
        
        // Migrate db if needed
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 6,
            migrationBlock: { migration, oldSchemaVersion in
                // Automatic migration
            }
        )
        
        
        // Setup global services
//        let meteor = MeteorService(serverURL: env.serverURL)
        // WARMING: Startup meteor before initializing accountService
        // so that account.state is initially correct
//        meteor.startup()

        //NSBundle.mainBundle().URLForResource("main", withExtension: "jsbundle");
        //NSURL("http://localhost:8081/index.ios.bundle?platform=ios&dev=true")

        let reactBundleURL = NSURL("http://localhost:8081/index.ios.bundle?platform=ios&dev=true")
        print(reactBundleURL)

        let bridge = RCTBridge(bundleURL: reactBundleURL, moduleProvider: nil, launchOptions: nil)
        let user = CurrentUser()
        _GlobalsContainer.instance = GlobalsContainer(env: env,
            analyticsService: AnalyticsService(env: env, currentUser: user),
            upgradeService: UpgradeService(env: env, currentUser: user),
            layerService: LayerService(layerAppID: env.layerURL, existingClient: layerClient),
            reactBridge: bridge
        )
//        let token = METAccount.defaultAccount().resumeToken
//        bridge.enqueueJSCall("ddp.loginWithToken", args: [token])

        
        layerClient = Globals.layerService.layerClient
        Globals.layerService.connectAndKeepUserInSync()

        // Startup the services
        SugarRecordLogger.currentLevel = SugarRecordLogger.logLevelError
        
        // Should be probably extracted into push service
        application.registerForRemoteNotifications()
        
        // Let's launch!
//        meteor.call("connectDevice", env.deviceId, [
//            "appId": env.appId,
//            "version": env.version,
//            "build": env.build
//        ])
        
        Log.info("App Launched")
        Analytics.track("AppOpen")
        
        Appearance.setupGlobalAppearances()
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
//        // BIG TODO: Should Instantiate different ViewControllers depending on onboarding or main
//        if !Globals.accountService.hasAccount() {
//            window?.rootViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateInitialViewController()
//        } else {
//            window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
//        }
        let vc = UIViewController()
        vc.view = RCTRootView(bridge: bridge, moduleName: "Taylr", initialProperties: nil)
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
//        NSURL *jsCodeLocation = [NSURL URLWithString:@"http://localhost:8081/index.ios.bundle"];
        // For production use, this `NSURL` could instead point to a pre-bundled file on disk:
        //
        //   NSURL *jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
        //
        // To generate that file, run the curl command and add the output to your main Xcode build target:
        //
        //   curl http://localhost:8081/index.ios.bundle -o main.jsbundle
//        let view = RCTRootView(bundleURL: NSURL("http://localhost:8081/index.ios.bundle?platform=ios"), moduleName: "SimpleApp", initialProperties: nil, launchOptions: nil)
//        RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
//        moduleName: @"SimpleApp"
//        launchOptions:nil];

        
        // Pre-heat the camera if we can
//        Async.background {
//            if AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) == .Authorized {
//                let recorder = SCRecorder.sharedRecorder()
//                recorder.captureSessionPreset = AVCaptureSessionPreset640x480
//                recorder.device = .Back
//                recorder.keepMirroringOnWrite = true
//                recorder.startRunning()
//            }
//        }
        VideoMakerViewController.preloadRecorderAsynchronously()
        return true
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        SugarRecord.applicationWillEnterForeground()
        Analytics.track("AppOpen")
        Globals.upgradeService.promptForUpgradeIfNeeded()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        Analytics.track("AppClose")
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        application.applicationIconBadgeNumber = 0 // Clear notification first
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // For some reason this causes a deadlock, so let's not do it
//        SugarRecord.applicationWillResignActive()
    }
    
    func applicationWillTerminate(application: UIApplication) {
//        SugarRecord.applicationWillTerminate()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return false
    }
    
    // MARK: - Push Handling
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        let nc = NSNotificationCenter.defaultCenter()
        nc.postNotificationName(AppDidRegisterUserNotificationSettings, object: notificationSettings)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Log.info("Registered for push \(deviceToken)")
        if let apsEnv = Globals.env.apsEnvironment?.rawValue {
//            MainContext.meteor.updateDevicePush(apsEnv, pushToken: deviceToken.hexString() as String)
            Analytics.setUserProperties(["RegisteredPush": true])
        } else if IS_TARGET_IPHONE_SIMULATOR == false {
            Log.error("Non-simulator build should have valid APS environment")
            // fatalError("Non-simulator build should have valid APS environment")
        }
        do {
            try layerClient.updateRemoteNotificationDeviceToken(deviceToken)
        } catch let error as NSError {
            Log.error("Unable to update Layer with push token", error)
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        Log.warn("Faild to register for push \(error)")
        Analytics.setUserProperties(["RegisteredPush": false])
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        Log.debug("Did receive notification \(userInfo)")
        // This is needed to handle remote notification while app is in the background
        // and therefore didFinishLaunching is never invoked.
        // TODO: LayerClient cannot be recreated, need to do again
        if layerClient == nil {
            let env = TaylrEnvironment.configureFromEmbeddedProvisioningProfile()
            layerClient = LayerService.defaultLayerClient(env.layerURL)
        }
        let handled = layerClient.synchronizeWithRemoteNotification(userInfo) { changes, error in
            if let error = error {
                Log.error("Failed to synchronize remote notification with layer", error)
                completionHandler(.Failed)
            } else {
                let changes = changes ?? []
                Log.info("Synchronized layer remote notification with \(changes.count) changes")
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
        // TODO: Better pattern for getting layerClient is needed
        if layerClient == nil {
            let env = TaylrEnvironment.configureFromEmbeddedProvisioningProfile()
            layerClient = LayerService.defaultLayerClient(env.layerURL)
        }
        layerClient.handleBackgroundContentTransfersForSession(identifier) { changes, error in
            if let error = error {
                Log.error("Failed to handle layer background transfer", error)
            } else {
                Log.info("Handled layer background transfer with \(changes?.count) changes")
            }
            completionHandler()
        }
    }
    
    // MARK: - Event Handling
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        if let touch = event?.allTouches()?.first,
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
