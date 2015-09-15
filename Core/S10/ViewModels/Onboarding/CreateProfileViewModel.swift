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
    let meteor: MeteorService
    let operationQueue: NSOperationQueue
    let subscription: MeteorSubscription
    public let avatar: MutableProperty<Image?>
    public let cover: MutableProperty<Image?>
    public let firstName: MutableProperty<String>
    public let lastName: MutableProperty<String>
    public let tagline: MutableProperty<String>
    public let about: MutableProperty<String>
    public let uploadImageAction: Action<(image: UIImage, type: PhotoTaskType), (), ErrorAlert>
    
    public init(meteor: MeteorService) {
        self.meteor = meteor
        let user = meteor.user.value!
        // Avoid names getting overwritten when user uploads avatar
        // and CoreData notifies changes to unrelated properties such as username
        // TODO: Think of better pattern
        firstName = MutableProperty(user.firstName ?? "")
        lastName = MutableProperty(user.lastName ?? "")
        tagline = MutableProperty("") // TODO: Turn this into major and grad year!@@!@#@#
        about = MutableProperty(user.about ?? "")
        avatar = user.pAvatar() |> mutable
        cover = user.pCover() |> mutable
        operationQueue = NSOperationQueue()
        let queue = operationQueue
        uploadImageAction = Action { tuple -> Future<(), ErrorAlert> in
            queue.addAsyncOperation {
                PhotoUploadOperation(meteor: meteor, image: tuple.image, taskType: tuple.type)
            } |> mapError { e in
                ErrorAlert(title: "Unable to upload", message: e.localizedDescription, underlyingError: e)
            }
        }
        subscription = meteor.subscribe("me")
    }
    
    public func saveProfile() -> Future<Void, ErrorAlert> {
        let promise = Promise<(), ErrorAlert>()

        var errorReason : String?

        if (firstName.value.nonBlank() == nil) {
            errorReason = "First name is required."
        } else if (lastName.value.nonBlank() == nil) {
            errorReason = "Last name is required."
        } else if (avatar.value == nil) {
            errorReason = "Avatar is required."
        }

        if let errorReason = errorReason {
            promise.failure(ErrorAlert(title: "Problem with Registration",
                message: errorReason))
        } else {
            var fields = [
                "firstName": firstName.value,
                "lastName": lastName.value,
            ]
            if let tagline = tagline.value.nonBlank() {
                fields["tagline"] = tagline
            }
            if let about = about.value.nonBlank() {
                fields["about"] = about
            }

            self.meteor.updateProfile(fields).subscribeError({ error in
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
        }

        return promise.future
    }
}