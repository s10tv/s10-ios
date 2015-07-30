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
    public enum Error : ErrorType {
        case Offline
        case FailedToUpdateAvatar
        case FailedToUpdateCover
        case FirstNameRequired
        case LastNameRequired
        case TaglineRequired
        
        public var alertTitle: String { return "" }
        public var alertBody: String { return "" }
        public var nsError: NSError { return NSError() }
    }
    
    let meteor: MeteorService
    let operationQueue = NSOperationQueue()
    public let avatar: PropertyOf<Image?>
    public let cover: PropertyOf<Image?>
    public let firstName: MutableProperty<String>
    public let lastName: MutableProperty<String>
    public let tagline: MutableProperty<String>
    public let about: MutableProperty<String>
    
    public init(meteor: MeteorService) {
        self.meteor = meteor
        let user = meteor.user.value!
        firstName = user.pFirstName() |> mutable
        lastName = user.pLastName() |> mutable
        about = user.pAbout() |> mutable
        avatar = user.pAvatar()
        cover = user.pCover()
        tagline = MutableProperty("")
    }
    
    // TODO: Add width & Height
    public func upload(image: UIImage, taskType: PhotoUploadOperation.TaskType) -> Future<(), NSError> {
        return operationQueue.addAsyncOperation {
            PhotoUploadOperation(meteor: meteor, image: image, taskType: taskType)
        }
    }
    
    public func saveProfile() -> Future<Void, Error> {
        let promise = Promise<(), Error>()
        return promise.future
    }
}