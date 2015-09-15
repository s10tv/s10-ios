//
//  EditProfileViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/14/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

public struct EditProfileViewModel {
    public let firstName: MutableProperty<String>
    public let lastName: MutableProperty<String>
    public let tagline: MutableProperty<String>
    public let about: MutableProperty<String>
    public let username: PropertyOf<String>
    public let avatar: PropertyOf<Image?>
    public let cover: PropertyOf<Image?>
    
    let operationQueue = NSOperationQueue()
    let meteor: MeteorService
    let user: User
    
    init(meteor: MeteorService, user: User) {
        self.meteor = meteor
        self.user = user
        firstName = user.pFirstName() |> mutable
        lastName = user.pLastName() |> mutable
        tagline = MutableProperty("") // TODO: Turn this major and gradYear
        about = user.pAbout() |> mutable
        username = user.pUsername()
        avatar = user.pAvatar()
        cover = user.pCover()
    }
    
    public func saveEdits() -> Future<(), ErrorAlert> {
        let promise = Promise<(), ErrorAlert>()
        // TODO: Add client side validation logic
        if firstName.value == user.firstName &&
            lastName.value == user.lastName &&
//            tagline.value == user.tagline && // TODO: Turn into major & class year
            about.value == user.about {
            // Early exit case
            promise.success()
        } else {
            meteor.updateProfile([
                "firstName": firstName.value,
                "lastName": lastName.value,
                "tagline": tagline.value,
                "about": about.value,
            ]).subscribeError({ error in
                promise.failure(ErrorAlert(title: "Unable to save", message: error.localizedDescription))
            }, completed: {
                promise.success()
            })
        }
        return promise.future
    }
    
    // MARK: -
    
    public func upload(image: UIImage, taskType: PhotoTaskType) -> Future<(), ErrorAlert> {
        return operationQueue.addAsyncOperation {
            PhotoUploadOperation(meteor: meteor, image: image, taskType: taskType)
        } |> mapError { e in
            ErrorAlert(title: "Unable to upload", message: e.localizedDescription, underlyingError: e)
        }
    }
}
