//
//  CoreService.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/3/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import ReactiveCocoa
import FacebookSDK
import SugarRecord
import Meteor
import TCMobileProvision

class CoreService {
    let serverHostname = "ketch-dev.herokuapp.com"

    let meteor : METCoreDataDDPClient
    let candidateService : CandidateService
    var mainContext : NSManagedObjectContext! {
        return meteor.mainQueueManagedObjectContext
    }
    var fbSession : FBSession {
        return FBSession.activeSession()!
    }
    var loginSignal = RACReplaySubject(capacity: 1)
    
    init() {
        meteor = METCoreDataDDPClient(serverURL: NSURL(string: "ws://\(serverHostname)/websocket"))
        
        // Set up CoreData
        SugarRecord.addStack(MeteorCDStack(meteor: meteor))
        
        // Setup Meteor
        meteor.logDDPMessages = true
        meteor.connect()
        
        meteor.addSubscriptionWithName("currentUser")
        meteor.addSubscriptionWithName("connections")
        meteor.addSubscriptionWithName("messages")
        
        meteor.defineStubForMethodWithName("connection/sendMessage", usingBlock: { (args) -> AnyObject! in
            assert(NSThread.isMainThread(), "Only main supported for now")
            let arguments = args as [String]
            if let connection = Connection.findByDocumentID(arguments.first!) {
                let message = Message.create() as Message
                message.connection = connection
                message.sender = User.currentUser()
                message.text = arguments[1]
                message.save()
            }
            return true
        })
        
        meteor.defineStubForMethodWithName("connection/markAsRead", usingBlock: { (args) -> AnyObject! in
            if let connection = Connection.findByDocumentID(args.first as String) {
                connection.hasUnreadMessage = false
                connection.save()
            }
            return true
        })

        // Initialize other services
        candidateService = CandidateService(meteor: meteor)
    }
    
    private func loginToMeteor() {
        let data = FBSession.activeSession().accessTokenData
        meteor.loginWithFacebook(data.accessToken, expiresAt: data.expirationDate).subscribeError({ error in
            println("login error \(error)")
        }, completed: {
            self.loginSignal.sendCompleted()
            println("login success")
        })
    }
    
    // TODO: What permissions do we actually need?
    private let fbReadPerms = [
        "user_about_me",
        "user_photos",
        "user_videos",
        "user_location",
        "user_work_history",
        "user_education_history",
        "user_birthday",
        // extended permissions
        "email"]
    
    func attemptLoginWithCachedCredentials() -> Bool {
        if meteor.hasAccount() {
            return true
        }
        if FBSession.openActiveSession(readPermissions: fbReadPerms) {
            loginToMeteor()
            return true
        }
        return false
    }
    
    func addPushToken(pushTokenData: NSData) {
        let mobileProvisionPath = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("embedded.mobileprovision")
        let mobileProvisionData = NSData.dataWithContentsOfMappedFile(mobileProvisionPath) as NSData
        let mobileProvision = TCMobileProvision(data: mobileProvisionData)
        let entitlements = mobileProvision.dict["Entitlements"] as NSDictionary
        let apsEnv = entitlements["aps-environment"] as NSString
        
        let appid = NSBundle.mainBundle().infoDictionary?["CFBundleIdentifier"] as NSString
        
        self.loginSignal.then({ () -> RACSignal! in
            return self.meteor.callMethod("user/addPushToken", params: [appid, apsEnv, pushTokenData.hexString()])
        }).subscribeError({ error in
            println("Failed to add push token \(error)")
        }, completed: {
            println("Succeeded sending push token to server")
        })
    }
    
    func loginWithUI() -> RACSignal {
        return FBSession.openActiveSessionWithUI(readPermissions: fbReadPerms).deliverOnMainThread().doCompleted {
            self.loginToMeteor()
        }.replay()
    }
    
    func logout() -> RACSignal {
        return meteor.logout().deliverOnMainThread().doCompleted({
            FBSession.activeSession().closeAndClearTokenInformation()
            self.mainContext.reset()
        }).replay()
    }
}