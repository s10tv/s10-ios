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

public struct RegisterEmailViewModel {
    public let registerEmailPlaceholder: String
    public let email: MutableProperty<String>

    let meteor: MeteorService

    public init(meteor: MeteorService) {
        self.meteor = meteor

        registerEmailPlaceholder = "School"
        email = MutableProperty(meteor.user.value.map {
            ($0.email ?? "").lowercaseString
        } ?? "")
    }

    public func saveEmail() -> Future<Void, ErrorAlert> {
        let promise = Promise<(), ErrorAlert>()
        self.meteor.registerEmail(email.value).subscribeError({ error in
            var errorReason : String
            if let reason = error.localizedFailureReason {
                errorReason = reason
            } else {
                errorReason = "Please try again later."
            }
            promise.failure(ErrorAlert(title: "Problem with Registration", message: errorReason))
            }, completed: {
                promise.success()
        })

        return promise.future
    }
}