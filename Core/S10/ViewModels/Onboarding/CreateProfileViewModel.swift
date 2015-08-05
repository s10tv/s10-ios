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
        firstName = user.pFirstName() |> mutable
        lastName = user.pLastName() |> mutable
        about = user.pAbout() |> mutable
        avatar = user.pAvatar() |> mutable
        cover = user.pCover() |> mutable
        tagline = MutableProperty("")
        operationQueue = NSOperationQueue()
        let queue = operationQueue
        uploadImageAction = Action { tuple -> Future<(), ErrorAlert> in
            queue.addAsyncOperation {
                PhotoUploadOperation(meteor: meteor, image: tuple.image, taskType: tuple.type)
            } |> mapError { e in
                ErrorAlert(title: .unableToUpload, message: e.localizedFailureReason, underlyingError: e)
            }
        }
        subscription = meteor.subscribe("me")
    }
    
    public func saveProfile() -> Future<Void, ErrorAlert> {
        let promise = Promise<(), ErrorAlert>()

        var errorReason: R.Strings?

        if (firstName.value.nonBlank() == nil) {
            errorReason = .firstNameMissing
        } else if (lastName.value.nonBlank() == nil) {
            errorReason = .lastNameMissing
        } else if (avatar.value == nil) {
            errorReason = .avatarMissing
        }

        if let errorReason = errorReason {
            promise.failure(ErrorAlert(title: .invalidRegistration, message: errorReason))
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
                let errorReason : String
                if let reason = error.localizedFailureReason {
                    errorReason = reason
                } else {
                    errorReason = LS(.tryAgainLater)
                }
                promise.failure(ErrorAlert(title: .cannotCreateProfile, message: errorReason))
            }, completed: {
                promise.success()
            })
        }

        return promise.future
    }
}
