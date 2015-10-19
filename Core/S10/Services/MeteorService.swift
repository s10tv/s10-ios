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
    private let _user = MutableProperty<User?>(nil)
    var mainContext : NSManagedObjectContext { return meteor.mainQueueManagedObjectContext }
    let meteor: METCoreDataDDPClient
    
    public let account: PropertyOf<METAccount?>
    public let connectionStatus: PropertyOf<METDDPConnectionStatus>
    public let loggedIn: PropertyOf<Bool>
    public let userId: PropertyOf<String?>
    public private(set) var currentUser: CurrentUser!
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
        super.init()
        meteor.delegate = self
        SugarRecord.addStack(MeteorCDStack(meteor: meteor))
        currentUser = CurrentUser(meteor: self)
    }

    public func startup() {
        meteor.account = METAccount.defaultAccount()
        meteor.connect()
    }
    
    public func userIdProducer() -> SignalProducer<String?, NoError> {
        return combineLatest(account.producer, userId.producer).flatMap(.Latest) { account, userId in
            if account != nil && userId == nil {
                return .empty
            }
            return SignalProducer(value: userId)
        }.skipRepeats { $0 == $1 }
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

    func completeProfile() -> Future<(), NSError> {
        return meteor.call("completeProfile")
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
    func searchHashtag(query: String) -> Future<[String], NSError> {
        return meteor.callMethod("hashtags/search", params: [query]).future.map {
            let json : [JSON] = JSON($0!).array!
            return json.map { $0["text"].string! }
        }
    }

    func insertHashtag(hashtag: String) -> Future<(), NSError> {
        return meteor.callMethod("me/hashtag/add", params: [hashtag], stub: { _ in
            if let tag = Hashtag.by(HashtagKeys.text.rawValue, value: hashtag).fetchFirst() as? Hashtag {
                tag.selected = true
            }
            // Figure out how to better latency compensate. This current way results in empty "#" getting created...
//            else {
//                let tag = Hashtag.create() as! Hashtag
//                tag.selected = true
//            }
            return nil
        }).future.map { _ in }
    }

    func removeHashtag(hashtag: String) -> Future<(), NSError> {
        return meteor.callMethod("me/hashtag/remove", params: [hashtag], stub: { _ in
            if let tag = Hashtag.by(HashtagKeys.text.rawValue, value: hashtag).fetchFirst() as? Hashtag {
                tag.selected = false
            }
            return nil
        }).future.map { _ in }
    }

    // MARK: - Users

    func blockUser(user: User) -> Future<(), NSError> {
        return meteor.call("user/block", user)
    }

    func reportUser(user: User, reason: String) -> Future<(), NSError> {
        return meteor.call("user/report", user, reason)
    }
    
    // MARK: - Tasks

    func startTask(taskId: String, type: String, metadata: NSDictionary) -> Future<AnyObject?, NSError> {
        return meteor.callMethod("startTask", params: [taskId, type, metadata]).future
    }
    
    func finishTask(taskId: String) -> Future<(), NSError> {
        return meteor.call("finishTask", taskId)
    }
    
    public func layerAuth(nonce: String) -> Future<String, NSError> {
        return meteor.callMethod("layer/auth", params: [nonce]).future.map { $0 as! String }
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
