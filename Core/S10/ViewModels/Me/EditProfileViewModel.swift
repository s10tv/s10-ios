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
    public let major: MutableProperty<String>
    public let gradYear: MutableProperty<String>
    public let hometown: MutableProperty<String>
    public let about: MutableProperty<String>
    public let avatar: PropertyOf<Image?>
    public let cover: PropertyOf<Image?>
    
    let operationQueue = NSOperationQueue()
    let meteor: MeteorService
    let user: User
    
    init(meteor: MeteorService, user: User) {
        self.meteor = meteor
        self.user = user
        firstName = user.pFirstName().mutable()
        lastName = user.pLastName().mutable()
        major = user.pMajor().mutable()
        gradYear = user.pGradYear().mutable()
        hometown = user.pHometown().mutable()
        about = user.pAbout().mutable()
        avatar = user.pAvatar()
        cover = user.pCover()
    }
    
    public func saveEdits() -> Future<(), ErrorAlert> {
        let promise = Promise<(), ErrorAlert>()
        // TODO: Add client side validation logic
        if firstName.value == user.firstName &&
            lastName.value == user.lastName &&
            major.value == user.major &&
            gradYear.value == user.gradYear &&
            hometown.value == user.hometown &&
            about.value == user.about {
            // Early exit case
            promise.success()
        } else {
            meteor.updateProfile([
                "firstName": firstName.value,
                "lastName": lastName.value,
                "major": major.value,
                "gradYear": gradYear.value,
                "hometown": hometown.value,
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
        }.mapError { e in
            ErrorAlert(title: "Unable to upload", message: e.localizedDescription, underlyingError: e)
        }.toFuture()
    }
}
