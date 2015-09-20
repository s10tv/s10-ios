//
//  UsernameViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/27/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Async

public struct VerifyCodeViewModel {
    public let code: MutableProperty<String>
    public let statusMessage: PropertyOf<String>
    public let statusColor: PropertyOf<UIColor>

    let meteor: MeteorService

    public init(meteor: MeteorService) {
        self.meteor = meteor
        code = MutableProperty("")

        // TODO
        statusMessage = PropertyOf("")
        statusColor = PropertyOf(UIColor.grayColor())
    }

    public func verifyCode() -> Future<Void, ErrorAlert> {
        let promise = Promise<(), ErrorAlert>()

        self.meteor.verifyCode(code.value).subscribeNext({ schoolName in
            // TODO: display this as an animation into statusMessage

        }, error: { error in
            var errorReason : String
            if let reason = error.localizedFailureReason {
                errorReason = reason
            } else {
                errorReason = "Please try again later."
            }
            promise.failure(ErrorAlert(title: "Registration Problem", message: errorReason))
        }, completed: {
            promise.success()
        })

        return promise.future
    }
}