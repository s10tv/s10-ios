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
    var meteor: MeteorClient!
    var rootVC: RootViewController! {
        get {
            return window?.rootViewController as RootViewController
        }
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        NSValueTransformer.setValueTransformer(PhotosValueTransformer(), forName: "PhotosValueTransformer")
        
        let stack: DefaultCDStack = DefaultCDStack(databaseName: "Database.sqlite", automigrating:true)
        SugarRecord.addStack(stack);
        
        debugCreateSugarRecordUser()
        
        meteor = MeteorClient(DDPVersion: "1")
        meteor.ddp = ObjectiveDDP(URLString: "ws://s10.herokuapp.com/websocket", delegate: meteor)
        meteor.ddp.connectWebSocket()

        // subscribe to "the allUsers" call, which populates the users collection.
        meteor.addSubscription("allUsers");
        
        // Need better way to register observer that unregisters itself
        NSNotificationCenter.defaultCenter().addObserverForName(MeteorClientConnectionReadyNotification, object: nil, queue: nil) { _ in
            // TODO: Need to connect after authenticating with fb, not just at app start
            if FBSession.openActiveSessionWithAllowLoginUI(false) {
                let data = FBSession.activeSession().accessTokenData
                println("Will login to meteor with fb \(data)")
                self.meteor.logonWithUserParameters(["fb-access": [
                    "accessToken": data.accessToken,
                    "expireAt": data.expirationDate.timeIntervalSince1970
                ]]) {
                    res, err in
                    println("res \(res) err \(err)")
                }
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reportConnection", name: MeteorClientDidConnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reportDisconnection", name: MeteorClientDidDisconnectNotification, object: nil)
        
        return true
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
    
    func reportConnection() {
        println("================> connected to server!")
    }
    
    func reportDisconnection() {
        println("================> disconnected from server!")
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
    }

    // DEBUGGING ONLY
    func debugCreateSugarRecordUser() -> Bool {
        var user: User = User.create() as User
        user.firstName = "Qiming"
        var photos : [Photo] = Array<Photo>()
        for index in 1...6 {
            let url = "https://s10.blob.core.windows.net/default/girl-00\(index).jpg"
            photos.append(Photo(url: url))
        }
        user.photos = photos
        
        return user.save()
    }
}
