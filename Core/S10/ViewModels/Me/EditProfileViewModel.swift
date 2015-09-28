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
    public let firstName = MutableProperty<String?>(nil)
    public let lastName = MutableProperty<String?>(nil)
    public let major = MutableProperty<String?>(nil)
    public let gradYear = MutableProperty<String?>(nil)
    public let hometown = MutableProperty<String?>(nil)
    public let about = MutableProperty<String?>(nil)
    public let avatar: PropertyOf<Image?>
    public let cover: PropertyOf<Image?>
    
    let operationQueue = NSOperationQueue()
    let meteor: MeteorService
    let user: User
    
    init(meteor: MeteorService, user: User) {
        self.meteor = meteor
        self.user = user
        avatar = user.pAvatar()
        cover = user.pCover()
        firstName <~ user.pFirstName()
        lastName <~ user.pLastName()
        major <~ user.pMajor()
        gradYear <~ user.pGradYear()
        hometown <~ user.pHometown()
        about <~ user.pAbout()
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
            // Separate variable here to reduce compilation time / inference duties
            let payload: [String: String] = [
                "firstName": firstName.value ?? "",
                "lastName": lastName.value ?? "",
                "major": major.value ?? "",
                "gradYear": gradYear.value ?? "",
                "hometown": hometown.value ?? "",
                "about": about.value ?? "",
            ]
            meteor.updateProfile(payload).subscribeError({ error in
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
