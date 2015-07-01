//
//  MeteorService.swift
//  Taylr
//
//  Created by Tony Xiao on 4/10/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import CoreLocation
import ReactiveCocoa
import SugarRecord
import Meteor

public class MeteorService {
    public let meteor: METCoreDataDDPClient
    public let subscriptions: (
        settings: METSubscription,
        metadata: METSubscription,
        discover: METSubscription,
        chats: METSubscription,
        messages: METSubscription,
        userData: METSubscription
    )
    public let collections: (
        metadata: METCollection,
        settings: METCollection,
        users: METCollection,
        candidates: METCollection,
        connections: METCollection,
        messages: METCollection,
        posts: METCollection,
        videos: METCollection
    )
    public let meta: Metadata
    public let settings: Settings
    
    // Proxied accessors
    public var networkReachable: Bool { return meteor.networkReachable }
    public var connectionStatus: METDDPConnectionStatus { return meteor.connectionStatus }
    public var connected: Bool { return meteor.connected }
    public var loggingIn: Bool { return meteor.loggingIn }
    public var mainContext : NSManagedObjectContext { return meteor.mainQueueManagedObjectContext }
    public var account: METAccount? { return meteor.account }
    public var userID : String? { return meteor.userID }
    public var user: User? { return userID.map { User.findByDocumentID(mainContext, documentID: $0) } ?? nil }
    public weak var delegate: METDDPClientDelegate? {
        get { return meteor.delegate }
        set { meteor.delegate = newValue }
    }
    
    public init(serverURL: NSURL) {
        let bundle = NSBundle(forClass: MeteorService.self)
        let model = NSManagedObjectModel.mergedModelFromBundles([bundle as AnyObject])
        meteor = METCoreDataDDPClient(serverURL: serverURL, account: nil, managedObjectModel: model)
        subscriptions = (
            settings: meteor.addSubscriptionWithName("settings"),
            metadata: meteor.addSubscriptionWithName("metadata"),
            discover: meteor.addSubscriptionWithName("discover"),
            chats: meteor.addSubscriptionWithName("chats"),
            messages: meteor.addSubscriptionWithName("messages"),
            userData: meteor.addSubscriptionWithName("userData")
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
    
    public func startup() {
        meteor.account = METAccount.defaultAccount()
        meteor.connect()
    }
    
    // MARK: - Publications
    
    public func subscribeServices(user: User) -> METSubscription {
        return meteor.addSubscriptionWithName("userServices", parameters: [user])
    }
    
    public func subscribeActivities(user: User) -> METSubscription {
        return meteor.addSubscriptionWithName("userActivities", parameters: [user])
    }
    
    public func unsubscribe(subscription: METSubscription?) {
        if let subscription = subscription {
            meteor.removeSubscription(subscription)
        }
    }
    
    // MARK: - Device
    
    public func connectDevice(env: Environment) -> RACSignal {
        // Technically this should be a barrier method, but barrier is not exposed by meteor-ios at the moment
        return meteor.call("connectDevice", [env.deviceId, [
            "appId": env.appId,
            "version": env.version,
            "build": env.build
        ]])
    }
    
    public func updateDevicePush(apsEnv: String, pushToken: String? = nil) -> RACSignal {
        return meteor.call("device/update/push", [[
            "apsEnv": apsEnv,
            "pushToken": pushToken ?? NSNull()
        ]])
    }
    
    public func updateDeviceLocation(location: CLLocation) -> RACSignal {
        return meteor.call("device/update/location", [[
            "lat": location.coordinate.latitude,
            "long": location.coordinate.longitude,
            "accuracy": location.horizontalAccuracy,
            "timestamp": location.timestamp
        ]])
    }
    
    // TODO: Add permission statuses for push, location, etc
    
    // MARK: - Authentication

    public func debugLoginWithUserId(userId: String) -> RACSignal {
        return meteor.loginWithMethod("login", params: [[
            "debug": ["userId": userId]
        ]])
    }
    
    public func loginWithDigits(#userId: String, authToken: String, authTokenSecret: String, phoneNumber: String) -> RACSignal {
        return meteor.loginWithMethod("login", params: [[
            "digits": [
                "userId": userId,
                "authToken": authToken,
                "authTokenSecret": authTokenSecret,
                "phoneNumber": phoneNumber
            ]
        ]])
    }
    
    public func loginWithFacebook(#accessToken: String, expiresAt: NSDate) -> RACSignal {
        return meteor.loginWithMethod("login", params: [[
            "fb-access": [
                "accessToken": accessToken,
                "expireAt": expiresAt.timeIntervalSince1970
            ]
        ]])
    }

    public func loginWithPhoneNumber(phoneNumber: String) -> RACSignal {
        return meteor.loginWithMethod("login", params: [[
            "phone-access": [
                "id": phoneNumber,
            ]
        ]])
    }
    
    public func logout() -> RACSignal {
        meteor.account = nil // No reason to wait for network to clear account
        return meteor.logout()
    }
    
    public func deleteAccount() -> RACSignal {
        return meteor.call("deleteAccount")
    }
    
    // MARK: - Services
    
    public func addService(serviceType: Service.ServiceType, accessToken: String) -> RACSignal {
        return meteor.call("me/service/add", [serviceType.rawValue, accessToken])
    }
    
    public func removeService(service: Service) -> RACSignal {
        return meteor.call("me/service/remove", [service])
    }

    // MARK: - Profile
    
    public func updateProfile(key: String, value: String) -> RACSignal {
        return meteor.call("me/update", [key, value]) {
//            User.currentUser()?.about = about
            return nil
        }
    }
    
    // MARK: - Candidates
    
    public func hideCandidate(candidate: Candidate) -> RACSignal {
        return meteor.call("candidate/hide", [candidate.documentID!], stub: {
            candidate.delete()
            return nil
        })
    }
    
    // MARK: - Users
    
    public func nudgeUser(user: User) -> RACSignal {
        return meteor.call("user/action", [user, "nudge"], stub: {
            return nil
        })
    }
    
    public func blockUser(user: User) -> RACSignal {
        return meteor.call("user/block", [user])
    }
    
    public func reportUser(user: User, reason: String) -> RACSignal {
        return meteor.call("user/report", [user, reason])
    }
    
    // MARK: - Messages
    
    public func openMessage(message: Message, expireDelay: Int = 30) -> RACSignal {
        return meteor.call("message/open", [message, expireDelay]) {
//            println("pre message \(message.documentID) status \(message.status) expire \(message.expiresAt)")
            message.statusEnum = .Opened
            message.expiresAt = NSDate(timeIntervalSinceNow: NSTimeInterval(expireDelay))
            if let connection = message.connection {
                connection.unreadCount = (connection.unreadCount?.intValue ?? 1) - 1
                connection.updatedAt = NSDate()
            }
            message.save()
//            println("post message \(message.documentID) status \(message.status) expire \(message.expiresAt)")
            return nil
        }
    }
    
    // MARK: - Tasks
    
    public func startVideoMessageTask(taskId: String, recipientId: String) -> RACSignal {
        return meteor.call("task/start", [taskId, "VideoMessage", ["recipientId": recipientId]])
    }
    
    public func startInviteTask(taskId: String, recipientInfo: String) -> RACSignal {
        return meteor.call("task/start", [taskId, "Invite", ["recipientInfo": recipientInfo]])
    }
    
    public func finishTask(taskId: String) -> RACSignal {
        return meteor.call("finishTask", [taskId])
    }
    
    public func startTask(taskId: String, type: String, metadata: NSDictionary) -> RACSignal {
        return meteor.call("startTask", [taskId, type, metadata])
    }
    
}
