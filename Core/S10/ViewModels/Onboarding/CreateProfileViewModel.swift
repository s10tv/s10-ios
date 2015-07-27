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
    
    public let avatar: PropertyOf<Image?>
    public let cover: PropertyOf<Image?>
    public let firstName: MutableProperty<String>
    public let lastName: MutableProperty<String>
    public let tagline: MutableProperty<String>
    public let aboutMe: MutableProperty<String>
    
    public func updateAvatar(image: UIImage, width: Int, height: Int) -> RACFuture<Void, Error> {
        let promise = RACPromise<(), Error>()
        return promise.future
    }

    public func updateCover(image: UIImage, width: Int, height: Int) -> RACFuture<Void, Error> {
        let promise = RACPromise<(), Error>()
        return promise.future
    }
    
    public func saveProfile() -> RACFuture<Void, Error> {
        let promise = RACPromise<(), Error>()
        return promise.future
    }
}