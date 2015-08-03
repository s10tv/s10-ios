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
                ErrorAlert(title: "Unable to upload", message: e.localizedDescription, underlyingError: e)
            }
        }
    }
    
    // TODO: Add width & Height
    public func upload(image: UIImage, taskType: PhotoTaskType) -> Future<(), NSError> {
        return operationQueue.addAsyncOperation {
            PhotoUploadOperation(meteor: meteor, image: image, taskType: taskType)
        }
    }
    
    public func saveProfile() -> Future<Void, ErrorAlert> {
        let promise = Promise<(), ErrorAlert>()

        var errorReason : String?

        if (firstName.value.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceCharacterSet()).length == 0) {
                errorReason = "Forgot to set first name?"
        } else if (lastName.value.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceCharacterSet()).length == 0) {
                errorReason = "Forgot to set last name?"
        } else if (tagline.value.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceCharacterSet()).length == 0) {
                errorReason = "Forgot to set tagline?"
        } else if (avatar.value == nil) {
            errorReason = "Forgot to upload avatar?"
        }

        if let errorReason = errorReason {
            promise.failure(ErrorAlert(title: "Problem with Registration",
                message: errorReason))
        } else {
            var fields = [
                "firstName": firstName.value,
                "lastName": lastName.value,
                "tagline": tagline.value,
            ]

            if self.about.value.stringByTrimmingCharactersInSet(
                NSCharacterSet.whitespaceCharacterSet()).length != 0 {
                    fields["about"] = self.about.value
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