//
//  MeteorService.swift
//  Ketch
//
//  Created by Tony Xiao on 4/10/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import ReactiveCocoa
import SugarRecord
import Meteor

class MeteorService {
    private let meteor: METCoreDataDDPClient
    let subscriptions: (
        metadata: METSubscription,
        currentUser: METSubscription,
        candidates: METSubscription,
        connections: METSubscription,
        messages: METSubscription
    )
    let collections: (
        metadata: METCollection,
        users: METCollection,
        candidates: METCollection,
        connections: METCollection,
        messages: METCollection
    )
    let meta: Metadata
    
    // Proxied accessors
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
    
    init(serverURL: NSURL) {
        meteor = METCoreDataDDPClient(serverURL: serverURL, account: nil)
        subscriptions = (
            meteor.addSubscriptionWithName("metadata"),
            meteor.addSubscriptionWithName("currentUser"),
            meteor.addSubscriptionWithName("candidates"),
            meteor.addSubscriptionWithName("connections"),
            meteor.addSubscriptionWithName("messages")
        )
        collections = (
            meteor.database.collectionWithName("metadata"),
            meteor.database.collectionWithName("users"),
            meteor.database.collectionWithName("candidates"),
            meteor.database.collectionWithName("connections"),
            meteor.database.collectionWithName("messages")
        )
        meta = Metadata(collection: collections.metadata)
        
        SugarRecord.addStack(MeteorCDStack(meteor: meteor))
    }
    
    func startup() {
        meteor.account = METAccount.defaultAccount()
        meteor.connect()
    }
    
    // MARK: - Authentication
    
    func loginWithFacebook(#accessToken: String, expiresAt: NSDate) -> RACSignal {
        return meteor.loginWithMethod("login", params: [[
            "fb-access": [
                "accessToken": accessToken,
                "expireAt": expiresAt.timeIntervalSince1970
            ]
        ]])
    }
    
    
    func logout() -> RACSignal {
        return meteor.logout()
    }

    // MARK: - Account Updates
    
    func registerDevice(env: Environment, pushToken: NSData? = nil) -> RACSignal {
        return meteor.call("me/update/device", [[
            "deviceId": env.deviceId,
            "appId": env.appId,
            "version": env.version,
            "build": env.build,
            "apsEnv": env.provisioningProfile?.apsEnvironment?.rawValue,
            "pushToken": pushToken?.hexString()
        ].filter { (k, v) in v != nil }.map { (k, v) in (k, v!) }])
    }

    func updateGenderPref(genderPref: GenderPref) -> RACSignal {
        return meteor.call("me/update/genderPref", [genderPref.rawValue]) {
            self.meta.setValue(genderPref.rawValue, metadataKey: "genderPref")
            return nil
        }
    }
    
    func updateHeight(heightInCm: Int) -> RACSignal {
        return meteor.call("me/update/height", [heightInCm]) {
            User.currentUser()?.height = heightInCm
            return nil
        }
    }
    
    func updateWork(work: String) -> RACSignal {
        return meteor.call("me/update/work", [work]) {
            User.currentUser()?.work = work
            return nil
        }
    }
    
    func updateEducation(education: String) -> RACSignal {
        return meteor.call("me/update/education", [education]) {
            User.currentUser()?.education = education
            return nil
        }
    }
    
    func updateAbout(about: String) -> RACSignal {
        return meteor.call("me/update/about", [about]) {
            User.currentUser()?.about = about
            return nil
        }
    }
    
    func deleteAccount() -> RACSignal {
        return meteor.call("me/delete")
    }
    
    // MARK: - Core Mechanic
    
    func submitChoices(#yes: Candidate, no: Candidate, maybe: Candidate) -> RACSignal {
        return meteor.call("candidate/submitChoices", [[
            "yes": yes.documentID!,
            "no": no.documentID!,
            "maybe": maybe.documentID!
        ]], stub: {
            [yes, no, maybe].map { $0.delete() }
            return nil
        }).map { result in
            if let yesId = (result as? NSDictionary)?["yes"] as? String {
                let connection = Connection.findByDocumentID(yesId)
                assert(connection != nil, "Expect new connection to exist by now")
                return connection
            }
            return nil
        }.deliverOnMainThread()
    }
    
    func markAsRead(connection: Connection) -> RACSignal {
        return meteor.call("connection/markAsRead", [connection.documentID!]) {
            connection.hasUnreadMessage = false
            connection.save()
            return nil
        }
    }
    
    func sendMessage(connection: Connection, text: String) -> RACSignal {
        return meteor.call("connection/sendMessage", [connection.documentID!, text]) {
            let message = Message.create() as Message
            message.connection = connection
            message.sender = User.currentUser()
            message.text = text
            message.save()
            return nil
        }
    }
    
    func reportUser(user: User, reason: String) -> RACSignal {
        return meteor.call("user/report", [user.documentID!, reason])
    }
}
