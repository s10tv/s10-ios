//
//  Haneke+Futures.swift
//  S10
//
//  Created by Tony Xiao on 7/9/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import BrightFutures
import Haneke

extension Cache {
    private class func errorWithCode(code: HanekeGlobals.Cache.ErrorCode) -> NSError {
        return NSError(domain: HanekeGlobals.Domain, code: code.rawValue, userInfo: nil)
    }
    
    func setValue(value : T, key: String) -> Future<T, NoError> {
        let promise = Promise<T, NoError>()
        set(value: value, key: key) { formattedValue in
            promise.success(formattedValue)
        }
        return promise.future
    }
    
    func fetch(key: String) -> Future<T, NSError> {
        let promise = Promise<T, NSError>()
        fetch(key: key, failure: { error in
            promise.failure(error ?? Cache.errorWithCode(.ObjectNotFound))
        }, success: {
            promise.success($0)
        })
        return promise.future
    }
    
    func pop(key: String) -> Future<T, NSError> {
        let future = fetch(key)
        remove(key: key)
        return future
    }
}