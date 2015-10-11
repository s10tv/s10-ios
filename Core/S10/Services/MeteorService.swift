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
import SwiftyJSON
import Meteor
import Async

public class MeteorService : NSObject {
    private var mainContext : NSManagedObjectContext { return meteor.mainQueueManagedObjectContext }
    private let _user = MutableProperty<User?>(nil)
    let meteor: METCoreDataDDPClient
    
    public let account: PropertyOf<METAccount?>
    public let connectionStatus: PropertyOf<METDDPConnectionStatus>
    public let loggedIn: PropertyOf<Bool>
    public let userId: PropertyOf<String?>
    public let settings: Settings
    public var offline: Bool { return !meteor.networkReachable }
    let user: PropertyOf<User?>

    public init(serverURL: NSURL) {
        let bundle = NSBundle(forClass: MeteorService.self)
        let model = NSManagedObjectModel.mergedModelFromBundles([bundle])
        meteor = METCoreDataDDPClient(serverURL: serverURL, account: nil, managedObjectModel: model)
        account = meteor.dyn("account").optional(METAccount).readonly()
        connectionStatus = meteor.dyn("connectionStatus").force(NSNumber)
            .map { METDDPConnectionStatus(rawValue: Int($0.intValue))! }
        user = PropertyOf(nil, _user.producer.observeOn(UIScheduler()))
        loggedIn = user.map { $0 != nil }
        userId = user.map { $0?.documentID }
        let name = "settings"
        let c = MeteorCollection(meteor.database.collectionWithName(name))
        let s = MeteorSubscription(meteor: meteor, subscription: meteor.addSubscriptionWithName(name))
        settings = Settings(collection: c, subscription: s)
        super.init()
        meteor.delegate = self
        SugarRecord.addStack(MeteorCDStack(meteor: meteor))
    }

    public func startup() {
        meteor.account = METAccount.defaultAccount()
        meteor.connect()
    }

    // MARK: - Publications & Collections & RPC

    func collection(name: String) -> MeteorCollection {
        return MeteorCollection(meteor.database.collectionWithName(name))
    }
    
    func subscribe(name: String, _ params: AnyObject...) -> MeteorSubscription {
        let sub = meteor.addSubscriptionWithName(name, parameters: params)
        return MeteorSubscription(meteor: meteor, subscription: sub)
    }
    
    public func call(name: String, _ params: AnyObject...) -> MeteorMethod {
        let promise = Promise<AnyObject?, NSError>()
        return MeteorMethod(stubValue: meteor.callMethodWithName(name, parameters: params) { res, error in
            if let error = error {
                promise.failure(error)
            } else {
                promise.success(res)
            }
        }, future: promise.future)
    }

    // MARK: - Device

    func connectDevice(env: Environment) -> Future<(), NSError> {
        // Technically this should be a barrier method, but barrier is not exposed by meteor-ios at the moment
        return meteor.call("connectDevice", env.deviceId, [
            "appId": env.appId,
            "version": env.version,
            "build": env.build
        ])
    }

    public func updateDevicePush(apsEnv: String, pushToken: String? = nil) -> Future<(), NSError> {
        return meteor.call("device/update/push", [
            "apsEnv": apsEnv,
            "pushToken": pushToken ?? NSNull()
        ])
    }

    public func updateDeviceLocation(location: CLLocation) -> Future<(), NSError> {
        return meteor.call("device/update/location", [
            "lat": location.coordinate.latitude,
            "long": location.coordinate.longitude,
            "accuracy": location.horizontalAccuracy,
            "timestamp": location.timestamp
        ])
    }

    // TODO: Add permission statuses for push, location, etc

    // MARK: - Authentication
    func login(type: String, _ serviceData: [String: AnyObject]) -> Future<(), NSError> {
        // HACK ALERT: Delegate callback does not happen in time for Meteor.user
        // to be populated by the time completion gets called.
        // Instead we will force compute the user before returning signal
        let promise = Promise<(), NSError>()
        meteor.login("login", [type: serviceData]).start(Event.sink(error: {
            promise.failure($0)
        }, completed: { [weak self] in
            if let userId = self?.meteor.userID {
                self?._user.value = self?.mainContext.objectInCollection("users", documentID: userId) as? User
            }
            // HACK ALERT: Bring back the 0.1 second delay to fix login...
            Async.main(after: 0.1) {
                promise.success()
            }
        }))
        return promise.future
    }
    
    public func loginWithDigits(userId userId: String, authToken: String, authTokenSecret: String, phoneNumber: String) -> Future<(), NSError> {
        return login("digits", [
            "userId": userId,
            "authToken": authToken,
            "authTokenSecret": authTokenSecret,
            "phoneNumber": phoneNumber
        ])
    }


    func loginWithFacebook(accessToken accessToken: String, expiresAt: NSDate) -> Future<(), NSError> {
        return login("fb-access", [
            "accessToken": accessToken,
            "expireAt": expiresAt.timeIntervalSince1970
        ])
    }

    public func logout() -> Future<(), NSError> {
        meteor.account = nil // No reason to wait for network to clear account
        return meteor.logout()
    }

    // MARK: -
    
    func verifyCode(code: String) -> Future<(), NSError> {
        return meteor.call("confirmInviteCode", code)
    }
    
    func confirmRegistration() -> Future<(), NSError> {
        return meteor.call("confirmRegistration")
    }

    // MARK: - Services

    public func addService(serviceTypeId: String, accessToken: String) -> Future<(), NSError> {
        return meteor.call("me/service/add", serviceTypeId, accessToken)
    }

    func removeService(serviceId: String) -> Future<(), NSError> {
        return meteor.call("me/service/remove", serviceId)
    }

    // MARK: - Profile

    func updateProfile(values: NSDictionary) -> Future<(), NSError> {
        return meteor.call("me/update", values)
    }

    // MARK: - Candidates

    func hideUser(user: User) -> Future<(), NSError> {
        return meteor.callMethod("user/hide", params: [user], stub: { _ in
            user.delete()
            return nil
        }).future.map { _ in }
    }

    // MARK: - Hashtags
    func searchHashtag(query: String) -> Future<[Hashtag], NSError> {
        return meteor.callMethod("hashtags/search", params: [query]).future.map {
            let json : [JSON] = JSON($0!).array!
            return json.map {
                return Hashtag(text: $0["text"].string!, selected: false)
            }
        }
    }

    func insertHashtag(hashtag: String) -> Future<(), NSError> {
        return meteor.call("me/hashtag/add", hashtag)
    }

    func removeHashtag(hashtag: String) -> Future<(), NSError> {
        return meteor.call("me/hashtag/remove", hashtag)
    }

    // MARK: - Users

    func blockUser(user: User) -> Future<(), NSError> {
        return meteor.call("user/block", user)
    }

    func reportUser(user: User, reason: String) -> Future<(), NSError> {
        return meteor.call("user/report", user, reason)
    }

    // MARK: - Messages
    
    func openMessage(message: Message) -> Future<(), NSError> {
        return meteor.callMethod("message/open", params: [message], stub: { _ in
            message.status_ = Message.Status.Opened.rawValue
            return nil
        }).future.map { _ in }
    }

    // MARK: - Tasks

    func startTask(taskId: String, type: String, metadata: NSDictionary) -> Future<AnyObject?, NSError> {
        return meteor.callMethod("startTask", params: [taskId, type, metadata]).future
    }
    
    func startMessageTask(taskId: String, recipient: ConversationId, info: [String: AnyObject]) -> Future<(videoURL: NSURL, thumbnailURL: NSURL), NSError> {
        var metadata = info
        switch recipient {
        case .ConnectionId(let connectionId):
            metadata["connectionId"] = connectionId
        case .UserId(let userId):
            metadata["userId"] = userId
        }
        return startTask(taskId, type: "MESSAGE", metadata: metadata).map {
            let json = JSON($0!)
            return (NSURL(json["videoUrl"].string!)!, NSURL(json["thumbnailUrl"].string!)!)
        }
    }
    
    func finishTask(taskId: String) -> Future<(), NSError> {
        return meteor.call("finishTask", taskId)
    }
}

extension MeteorService : METDDPClientDelegate {
    // MARK: Meteor Logging

    public func client(client: METDDPClient, willSendDDPMessage message: [NSObject : AnyObject]) {
        Log.verbose("DDP > \(message)")
    }
    public func client(client: METDDPClient, didReceiveDDPMessage message: [NSObject : AnyObject]) {
        Log.verbose("DDP < \(message)")
    }

    public func client(client: METDDPClient, didSucceedLoginToAccount account: METAccount) {
        let user = self.mainContext.objectInCollection("users", documentID: account.userID) as? User
        assert(user != nil, "User must exist after account logs in")
        _user.value = user
    }

    public func client(client: METDDPClient, didFailLoginWithWithError error: NSError) {
        _user.value = nil
    }

    public func clientDidLogout(client: METDDPClient) {
        _user.value = nil
    }
}
