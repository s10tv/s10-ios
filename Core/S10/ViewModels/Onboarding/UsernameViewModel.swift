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

public struct UsernameViewModel {
    public let usernamePlaceholder: String
    public let username: MutableProperty<String>
    public let statusImage: PropertyOf<Image?>
    public let hideSpinner: PropertyOf<Bool>
    public let statusMessage: PropertyOf<String>
    public let statusColor: PropertyOf<UIColor>
    
    let meteor: MeteorService
    
    public init(meteor: MeteorService) {
        self.meteor = meteor
        usernamePlaceholder = "tswift"
        username = MutableProperty("")
        statusImage = PropertyOf(nil)
        hideSpinner = PropertyOf(true)
        
        statusMessage = PropertyOf("", username.producer
            |> skip(1)
            |> map { username -> String in
                if username.length < 4 {
                    return "Username must be at least 4 characters"
                }
                if username.length > 20 {
                    return "Username must be at less than 20 characters"
                }
                return ""
            }
        )
        statusColor = PropertyOf(UIColor.blackColor(), statusMessage.producer
            |> map {
                $0.length > 0 ? UIColor.redColor() : UIColor.blackColor()
            }
        )
    }
    
    public func saveUsername() -> Future<Void, ErrorAlert> {
        let promise = Promise<(), ErrorAlert>()
        self.meteor.confirmRegistration(username.value).subscribeError({ error in
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