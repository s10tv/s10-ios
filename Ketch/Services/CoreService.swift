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

class CoreService : NSObject {
    var flow: FlowService!
    var meteorService: MeteorService!
    var meteor : METCoreDataDDPClient!
    var meta: MetadataService!
    var mainContext : NSManagedObjectContext! {
        return meteor.mainQueueManagedObjectContext
    }
    var fbSession : FBSession {
        return FBSession.activeSession()!
    }
    
    override init() {
        super.init()
        meteorService = MeteorService(serverURL: Env.serverURL)
        meteor = meteorService.meteor
        SugarRecord.addStack(MeteorCDStack(meteor: meteor))
        meta = MetadataService(meteor: meteor)
        flow = FlowService(meteorService: meteorService, metadataService: meta)
        
        // Set up CoreData
        
        // Setup Meteor
        meteor.connect()
        
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

        
        // TODO: This is really quite right, need to rethink flow diagram here
        attemptLoginWithCachedCredentials()
    }
    
    private func loginToMeteor() {
        let data = FBSession.activeSession().accessTokenData
        meteor.loginWithFacebook(data.accessToken, expiresAt: data.expirationDate)
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
        // TODO: Only call this after user logged in
        if let apsEnv = Env.provisioningProfile?.apsEnvironment?.rawValue {
            meteor.callMethod("user/addPushToken", params: [Env.appID, apsEnv, pushTokenData.hexString()])
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
        return meteor.logout().deliverOnMainThread() // TODO: Log out needs to reset the METDatabase
    }
}
