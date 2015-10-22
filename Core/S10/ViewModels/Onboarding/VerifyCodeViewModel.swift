//
//  VerifyCodeViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/27/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Async

public struct VerifyCodeViewModel {

    let ctx: Context

    public init(_ ctx: Context) {
        self.ctx = ctx
    }

    public func joinUBCNetwork(token: String) -> Future<Void, ErrorAlert> {
        let promise = Promise<(), ErrorAlert>()
        // TODO: display this as an animation into statusMessage
        ctx.meteor.joinNetwork("ubc", token: token).onFailure { error in
            var errorReason : String
            if let reason = error.localizedFailureReason {
                errorReason = reason
            } else {
                errorReason = "Please try again later."
            }
            promise.failure(ErrorAlert(title: "Registration Problem", message: errorReason))
        }.onSuccess {
            promise.success()
        }
        return promise.future.deliverOn(UIScheduler())
    }
}