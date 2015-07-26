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
    public let about: MutableProperty<String>
    public let username: PropertyOf<String>
    public let avatarImage: PropertyOf<Image?>
    public let coverImage: PropertyOf<Image?>
    
    let operationQueue = NSOperationQueue()
    let meteor: MeteorService
    let user: User
    
    init(meteor: MeteorService, user: User) {
        self.meteor = meteor
        self.user = user
        firstName = user.pFirstName() |> mutable
        lastName = user.pLastName() |> mutable
        about = user.pAbout() |> mutable
        username = user.pUsername()
        avatarImage = user.pAvatar()
        coverImage = user.pCover()
    }
    
    public func saveEdits() -> RACFuture<(), NSError> {
        let promise = RACPromise<(), NSError>()
        // TODO: Add client side validation logic
        if firstName.value == user.firstName &&
            lastName.value == user.lastName &&
            about.value == user.about {
            // Early exit case
            promise.success()
        } else {
            meteor.updateProfile([
                "firstName": firstName.value,
                "lastName": lastName.value,
                "about": about.value,
            ]).subscribeErrorOrCompleted {
                $0.map { promise.failure($0) } ?? promise.success()
            }
        }
        return promise.future
    }
    
    // MARK: -
    
    public func upload(image: UIImage, taskType: PhotoUploadOperation.TaskType) -> RACFuture<(), NSError> {
        return operationQueue.addAsyncOperation {
            PhotoUploadOperation(meteor: meteor, image: image, taskType: taskType)
        }.signalProducer() |> toFuture
    }
}
