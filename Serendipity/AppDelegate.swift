//
//  AppDelegate.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/24/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import CoreData
import FacebookSDK
import ObjectiveDDP
import SugarRecord

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var networkManager: NetworkManager!

    var rootVC: RootViewController! {
        get {
            return window?.rootViewController as RootViewController
        }
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        NSValueTransformer.setValueTransformer(PhotosValueTransformer(), forName: "PhotosValueTransformer")
        
        // sets up core data stack
        let stack: DefaultCDStack = DefaultCDStack(databaseName: "Database.sqlite", automigrating:true)
        SugarRecord.addStack(stack);
        
        // sets up objective ddp networking stack
        self.networkManager = NetworkManager(wsAddress: "ws://s10.herokuapp.com/websocket")
        self.networkManager.startPubsub()

        // Need better way to register observer that unregisters itself
        NSNotificationCenter.defaultCenter().addObserverForName(MeteorClientConnectionReadyNotification, object: nil, queue: nil) { _ in
            // TODO: Need to connect after authenticating with fb, not just at app start
            if FBSession.openActiveSessionWithAllowLoginUI(false) {
                let data = FBSession.activeSession().accessTokenData
                let userParam: [NSObject : AnyObject]! = ["fb-access": [
                    "accessToken": data.accessToken,
                    "expireAt": data.expirationDate.timeIntervalSince1970
                ]]
                
                self.networkManager.logIn(userParam, self.userLoggedIn);
            }
        }
        
        return true
    }
    
    func userLoggedIn(res : [NSObject : AnyObject]!, err : NSError!) -> Void {
        println(res);
        println(err);
    }
    
    func applicationWillResignActive(application: UIApplication!) {
        SugarRecord.applicationWillResignActive()
    }
    
    func applicationWillEnterForeground(application: UIApplication!) {
        SugarRecord.applicationWillEnterForeground()
    }
    
    func applicationWillTerminate(application: UIApplication!) {
        SugarRecord.applicationWillTerminate()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBAppCall.handleDidBecomeActive()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
    }
}
