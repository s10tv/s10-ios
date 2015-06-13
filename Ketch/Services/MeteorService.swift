//
//  MeteorService.swift
//  Ketch
//
//  Created by Tony Xiao on 4/10/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import CoreLocation
import ReactiveCocoa
import SugarRecord
import Meteor

class MeteorService {
    private let meteor: METCoreDataDDPClient
    let env: Environment
    let subscriptions: (
        settings: METSubscription,
        metadata: METSubscription,
        discover: METSubscription,
        chats: METSubscription,
        me: METSubscription
    )
    let collections: (
        metadata: METCollection,
        settings: METCollection,
        users: METCollection,
        candidates: METCollection,
        connections: METCollection,
        messages: METCollection,
        posts: METCollection,
        videos: METCollection
    )
    let meta: Metadata
    let settings: Settings
    
    // Proxied accessors
    var networkReachable: Bool { return meteor.networkReachable }
    var connectionStatus: METDDPConnectionStatus { return meteor.connectionStatus }
    var connected: Bool { return meteor.connected }
    var loggingIn: Bool { return meteor.loggingIn }
    var mainContext : NSManagedObjectContext { return meteor.mainQueueManagedObjectContext }
    var account: METAccount? { return meteor.account }
    var userID : String? { return meteor.userID }
    weak var delegate: METDDPClientDelegate? {
        get { return meteor.delegate }
        set { meteor.delegate = newValue }
    }
    
    init(env: Environment) {
        self.env = env
        meteor = METCoreDataDDPClient(serverURL: env.serverURL, account: nil)
        subscriptions = (
            settings: meteor.addSubscriptionWithName("settings"),
            metadata: meteor.addSubscriptionWithName("metadata"),
            discover: meteor.addSubscriptionWithName("discover"),
            chats: meteor.addSubscriptionWithName("chats"),
            me: meteor.addSubscriptionWithName("me")
        )
        collections = (
            metadata: meteor.database.collectionWithName("metadata"),
            settings: meteor.database.collectionWithName("settings"),
            users: meteor.database.collectionWithName("users"),
            candidates: meteor.database.collectionWithName("candidates"),
            connections: meteor.database.collectionWithName("connections"),
            messages: meteor.database.collectionWithName("messages"),
            posts: meteor.database.collectionWithName("posts"),
            videos: meteor.database.collectionWithName("videos")
        )
        meta = Metadata(collection: collections.metadata)
        settings = Settings(collection: collections.settings)
        SugarRecord.addStack(MeteorCDStack(meteor: meteor))
    }
    
    func startup() {
        meteor.account = METAccount.defaultAccount()
        meteor.connect()
        connectDevice(env)
    }
    
    // MARK: - Device
    
    private func connectDevice(env: Environment) -> RACSignal {
        // Technically this should be a barrier method, but barrier is not exposed by meteor-ios at the moment
        return meteor.call("connectDevice", [env.deviceId, [
            "appId": env.appId,
            "version": env.version,
            "build": env.build
        ]])
    }
    
    func updateDevicePush(apsEnv: String, pushToken: String? = nil) -> RACSignal {
        return meteor.call("device/update/push", [[
            "apsEnv": apsEnv,
            "pushToken": pushToken ?? NSNull()
        ]])
    }
    
    func updateDeviceLocation(location: CLLocation) -> RACSignal {
        return meteor.call("device/update/location", [[
            "lat": location.coordinate.latitude,
            "long": location.coordinate.longitude,
            "accuracy": location.horizontalAccuracy,
            "timestamp": location.timestamp
        ]])
    }
    
    // TODO: Add permission statuses for push, location, etc
    
    // MARK: - Authentication

    func debugLoginWithUserId(userId: String) -> RACSignal {
        return meteor.loginWithMethod("login", params: [[
            "debug": ["userId": userId]
        ]])
    }
    
    func loginWithFacebook(#accessToken: String, expiresAt: NSDate) -> RACSignal {
        return meteor.loginWithMethod("login", params: [[
            "fb-access": [
                "accessToken": accessToken,
                "expireAt": expiresAt.timeIntervalSince1970
            ]
        ]])
    }
    
    func logout() -> RACSignal {
        meteor.account = nil // No reason to wait for network to clear account
        return meteor.logout()
    }
    
    func deleteAccount() -> RACSignal {
        return meteor.call("deleteAccount")
    }
    
    // MARK: - User
    
    func updateProfile(key: String, value: String) -> RACSignal {
        return meteor.call("me/update", [key, value]) {
//            User.currentUser()?.about = about
            return nil
        }
    }
    
    // MARK: - Core Mechanic
    
    func hideCandidate(candidate: Candidate) -> RACSignal {
        return meteor.call("candidate/hide", [candidate.documentID!], stub: {
            candidate.delete()
            return nil
        })
    }
    
    func markAsRead(message: Message) -> RACSignal {
        return meteor.call("message/markAsRead", [message.documentID!]) {
            message.status = "read" // TODO: Fixme
            message.save()
            return nil
        }
    }
    
    func sendMessage(connection: Connection, video: Video) -> RACSignal {
        return meteor.call("Connection/sendMessage", [connection.documentID!, video.documentID!]) {
            let message = Message.create() as! Message
            message.connection = connection
            message.sender = User.currentUser()
            message.video = video
            message.save()
            return nil
        }
    }
    
    func reportUser(user: User, reason: String) -> RACSignal {
        return meteor.call("user/report", [user.documentID!, reason])
    }
    

}
