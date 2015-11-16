//
//  MeteorExtensions.swift
//  S10
//
//  Created by Tony Xiao on 10/4/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import Meteor
import ReactiveCocoa

extension METDDPClient {
    
    func callMethod(method: String, params: [AnyObject]? = nil, stub: METMethodStub? = nil) -> MeteorMethod {
        let promise = Promise<AnyObject?, NSError>()
        return MeteorMethod(stubValue: callMethodWithName(method, parameters: params, completionHandler: { res, error in
            if let error = error {
                promise.failure(error)
            } else {
                promise.success(res)
            }
        }, methodStub: stub), future: promise.future)
    }
    
    func subscribe(name: String, params: [AnyObject]? = nil) -> MeteorSubscription {
        let sub = addSubscriptionWithName(name, parameters: params)
        return MeteorSubscription(meteor: self, subscription: sub)
    }
    
    func collection(name: String) -> MeteorCollection {
        return MeteorCollection(database.collectionWithName(name))
    }
    
    // MARK: -
    
    func sub(name: String, _ params: AnyObject...) -> MeteorSubscription {
        return subscribe(name, params: params)
    }
    
    func call(method: String, _ params: AnyObject...) -> Future<(), NSError> {
        return callMethod(method, params: params).future.map { _ in }
    }
    
    func login(method: String, _ params: AnyObject...) -> Future<(), NSError> {
        let promise = Promise<(), NSError>()
        loginWithMethodName(method, parameters: params) { error in
            if let error = error {
                promise.failure(error)
            } else {
                promise.success()
            }
        }
        return promise.future
    }
    
    func logout() -> Future<(), NSError> {
        let promise = Promise<(), NSError>()
        logoutWithCompletionHandler { error in
            if let error = error {
                promise.failure(error)
            } else {
                promise.success()
            }
        }
        return promise.future
    }
}
