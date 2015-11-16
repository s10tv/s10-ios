//
//  AccountService.swift
//  Taylr
//
//  Created by Tony Xiao on 2/3/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import ReactiveCocoa
import DigitsKit
import Core

extension Digits {
    func authenticate() -> Future<DGTSession, NSError> {
        let promise = Promise<DGTSession, NSError>()
        authenticateWithCompletion { (session: DGTSession?, error: NSError?) in
            if let session = session {
                promise.success(session)
            } else if let error = error where error.code == DGTErrorCode.UserCanceledAuthentication.rawValue {
                promise.cancel()
            } else if let error = error {
                promise.failure(error)
            } else {
                assertionFailure("Should either succeed or fail")
            }
        }
        return promise.future
    }
}

