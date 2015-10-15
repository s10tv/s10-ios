//
//  CreateProfileViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/27/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

public struct CreateProfileViewModel {
    let ctx: Context
    let operationQueue: NSOperationQueue
    let subscription: MeteorSubscription
    public let avatar: MutableProperty<Image?>
    public let cover: MutableProperty<Image?>
    public let firstName: MutableProperty<String?>
    public let lastName: MutableProperty<String?>
    public let major: MutableProperty<String?>
    public let year: MutableProperty<String?>
    public let hometown: MutableProperty<String?>
    public let about: MutableProperty<String?>
    public let uploadImageAction: Action<(image: UIImage, type: PhotoTaskType), (), ErrorAlert>
    
    public init(ctx: Context) {
        self.ctx = ctx
        let user = ctx.meteor.user.value!
        // Avoid names getting overwritten when user uploads avatar
        // and CoreData notifies changes to unrelated properties such as username
        // TODO: Think of better pattern
        firstName = MutableProperty(user.firstName)
        lastName = MutableProperty(user.lastName)
        about = MutableProperty(user.about)
        avatar = user.pAvatar().mutable()
        cover = user.pCover().mutable()
        hometown = MutableProperty(user.hometown)
        major = MutableProperty(user.major)
        year = MutableProperty(user.gradYear)
        operationQueue = NSOperationQueue()
        let queue = operationQueue
        uploadImageAction = Action { tuple -> Future<(), ErrorAlert> in
            queue.addAsyncOperation {
                PhotoUploadOperation(meteor: ctx.meteor, image: tuple.image, taskType: tuple.type)
            }.mapError { e in
                ErrorAlert(title: "Unable to upload", message: e.localizedDescription, underlyingError: e)
            }.toFuture()
        }
        subscription = ctx.meteor.subscribe("me")
    }
    
    public func saveProfile() -> Future<Void, ErrorAlert> {
        let promise = Promise<(), ErrorAlert>()

        var errorReason : String?

        if (firstName.value?.nonBlank() == nil) {
            errorReason = "First name is required."
        } else if (lastName.value?.nonBlank() == nil) {
            errorReason = "Last name is required."
        } else if (avatar.value == nil) {
            errorReason = "Avatar is required."
        }

        if let errorReason = errorReason {
            promise.failure(ErrorAlert(title: "Problem with Registration",
                message: errorReason))
        } else {
            var fields = [
                "firstName": firstName.value!,
                "lastName": lastName.value!,
            ]
            if let about = about.value?.nonBlank() {
                fields["about"] = about
            }
            if let hometown = hometown.value?.nonBlank() {
                fields["hometown"] = hometown
            }
            if let major = major.value?.nonBlank() {
                fields["major"] = major
            }
            if let year = year.value?.nonBlank() {
                fields["gradYear"] = year
            }
            
            ctx.meteor.updateProfile(fields).flatMap {
                self.ctx.meteor.completeProfile()
            }.onFailure { error in
                var errorReason : String
                if let reason = error.localizedFailureReason {
                    errorReason = reason
                } else {
                    errorReason = "Please try again later."
                }
                promise.failure(ErrorAlert(title: "Problem with Registration", message: errorReason))
            }.onSuccess {
                promise.success()
            }
        }

        return promise.future
    }
    
    public func confirmRegistration() -> Future<Void, ErrorAlert> {
        return ctx.meteor.confirmRegistration().mapError { error in
            var errorReason : String
            if let reason = error.localizedFailureReason {
                errorReason = reason
            } else {
                errorReason = "Please try again later."
            }
            return ErrorAlert(title: "Problem with Registration", message: errorReason)
        }.toFuture()
    }
}