//
//  EditProfileInteractor.swift
//  S10
//
//  Created by Tony Xiao on 7/14/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

public class EditProfileInteractor {
    public let firstName: MutableProperty<String>
    public let lastName: MutableProperty<String>
    public let about: MutableProperty<String>
    public let username: PropertyOf<String>
    public let avatarImageURL: PropertyOf<NSURL?>
    public let coverImageURL: PropertyOf<NSURL?>
    
    let operationQueue = NSOperationQueue()
    let meteor: MeteorService
    let user: User
    
    public init(meteor: MeteorService, user: User) {
        self.meteor = meteor
        self.user = user
        firstName = user.dyn("firstName").optional(String) |> map { $0 ?? "" } |> mutable
        lastName = user.dyn("lastName").optional(String) |> map { $0 ?? "" } |> mutable
        about = user.dyn("about").optional(String) |> map { $0 ?? "" } |> mutable
        username = user.dyn("username").optional(String) |> map { $0 ?? "" }
        avatarImageURL = user.dyn("avatar").optional(Image) |> map { $0?.url }
        coverImageURL = user.dyn("cover").optional(Image) |> map { $0?.url }
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
