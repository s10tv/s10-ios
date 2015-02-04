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
import SugarRecord
import ReactiveCocoa
import Meteor

let Meteor = METDDPClient(serverURL: NSURL(string: "ws://s10.herokuapp.com/websocket"))

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var rootVC: RootViewController! {
        get {
            return window?.rootViewController as RootViewController
        }
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "METShouldLogDDPMessages")
        
        NSValueTransformer.setValueTransformer(PhotosValueTransformer(), forName: "PhotosValueTransformer")
        
        // sets up core data stack
        let stack: DefaultCDStack = DefaultCDStack(databaseName: "Database.sqlite", automigrating:true)
        SugarRecord.addStack(stack);
        
        // TODO: Need to connect after authenticating with fb, not just at app start
        if FBSession.openActiveSessionWithAllowLoginUI(false) {
            let data = FBSession.activeSession().accessTokenData
            let userParam = [["fb-access": [
                "accessToken": data.accessToken,
                "expireAt": data.expirationDate.timeIntervalSince1970
            ]]]
            Meteor.loginWithMethodName("login", parameters: userParam, completionHandler: { err in
                println("Logged in? \(err)")
            })
        }
        
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
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
    }
}
