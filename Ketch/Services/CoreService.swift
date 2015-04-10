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

class CoreService {
    let flow = FlowService()
    let meteor : METCoreDataDDPClient
    let meta: MetadataService
    let candidateService : CandidateService
    var mainContext : NSManagedObjectContext! {
        return meteor.mainQueueManagedObjectContext
    }
    var fbSession : FBSession {
        return FBSession.activeSession()!
    }
    var loginSignal = RACReplaySubject(capacity: 1)
    var currentUserSubscription : METSubscription!
    var connectionsSubscription : METSubscription!
    
    init() {
        meteor = METCoreDataDDPClient(serverURL: Env.serverURL)
        
        // Set up CoreData
        SugarRecord.addStack(MeteorCDStack(meteor: meteor))
        
        // Setup Meteor
        meteor.logDDPMessages = true
        meteor.connect()
        
        currentUserSubscription = meteor.addSubscriptionWithName("currentUser")
        connectionsSubscription = meteor.addSubscriptionWithName("connections")
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
        meta = MetadataService(meteor: meteor)
        
        // TODO: This is really quite right, need to rethink flow diagram here
        NC.postNotification(.WillLoginToMeteor)
        attemptLoginWithCachedCredentials()
        
        currentUserSubscription.signal.subscribeError({ _ in
            NC.postNotification(.DidFailLoginToMeteor)
        }, completed: {
            NC.postNotification(.DidSucceedLoginToMeteor)
        })
    }
    
    private func loginToMeteor() {
        let data = FBSession.activeSession().accessTokenData
        meteor.loginWithFacebook(data.accessToken, expiresAt: data.expirationDate).subscribeError({ error in
            
        }, completed: {
            self.loginSignal.sendCompleted()
        })
    }
    
    // TODO: What permissions do we actually need?
    private let fbReadPerms = [
        "user_about_me",
        "user_photos",
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
        NC.postNotification(.DidFailLoginToMeteor)
        return false
    }
    
    func addPushToken(pushTokenData: NSData) {
        if let apsEnv = Env.provisioningProfile?.apsEnvironment?.rawValue {
            // TODO: This doesn't seem to update on app force kill and restart, but it should
            self.loginSignal.then({ () -> RACSignal! in
                return self.meteor.callMethod("user/addPushToken", params: [Env.appID, apsEnv, pushTokenData.hexString()])
            }).subscribeError({ error in
                println("Failed to add push token \(error)")
                }, completed: {
                    println("Succeeded sending push token to server")
            })
        }
    }
    
    func loginWithUI() -> RACSignal {
        return FBSession.openActiveSessionWithUI(readPermissions: fbReadPerms).deliverOnMainThread().doCompleted {
            self.loginToMeteor()
        }.replay()
    }
    
    func logout() -> RACSignal {
        FBSession.activeSession().closeAndClearTokenInformation()
        mainContext.reset()
        UD.resetAll()
        return meteor.logout().deliverOnMainThread()
    }
}