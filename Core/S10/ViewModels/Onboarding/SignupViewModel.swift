//
//  SignupInteractor.swift
//  S10
//
//  Created by Tony Xiao on 7/2/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

public struct SignupViewModel {
    let meteor: MeteorService
    let user: User
    let operationQueue = NSOperationQueue()
    public let avatar: PropertyOf<Image?>
    public let cover: PropertyOf<Image?>
    public let firstName: MutableProperty<String>
    public let lastName: MutableProperty<String>
    public let username: MutableProperty<String>
    public let about: MutableProperty<String>
    
    public init(meteor: MeteorService) {
        self.meteor = meteor
        self.user = meteor.user.value!
        firstName = user.pFirstName() |> mutable
        lastName = user.pLastName() |> mutable
        username = user.pUsername() |> mutable
        about = user.pAbout() |> mutable
        avatar = user.pAvatar()
        cover = user.pCover()
    }
    
    public func uploadAvatar(image: UIImage) -> Future<(), NSError> {
        return upload(image, taskType: .ProfilePic)
    }
    
    public func uploadCoverPhoto(image: UIImage) -> Future<(), NSError> {
        return upload(image, taskType: .CoverPic)
    }
    
    // MARK: -
    
    func upload(image: UIImage, taskType: PhotoTaskType) -> Future<(), NSError> {
        return operationQueue.addAsyncOperation {
            PhotoUploadOperation(meteor: meteor, image: image, taskType: taskType)
        }
    }
}