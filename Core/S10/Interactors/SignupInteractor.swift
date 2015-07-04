//
//  SignupInteractor.swift
//  S10
//
//  Created by Tony Xiao on 7/2/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Bond

public class SignupInteractor {
    let meteor: MeteorService
    let user: User
    let operationQueue = NSOperationQueue()
    public let firstName = Dynamic("")
    public let lastName = Dynamic("")
    public let username = Dynamic("")
    public let about = Dynamic("")
    
    public init(meteor: MeteorService, user: User) {
        self.meteor = meteor
        self.user = user
        user.dynFirstName.map { $0 ?? "" } ->> firstName
        user.dynLastName.map { $0 ?? "" } ->> lastName
        user.dynUsername.map { $0 ?? "" } ->> username
        user.dynAbout.map { $0 ?? "" } ->> about
    }
    
    public func uploadAvatar(image: UIImage) -> RACSignal {
        return upload(image, taskType: .ProfilePic)
    }
    
    public func uploadCoverPhoto(image: UIImage) -> RACSignal {
        return upload(image, taskType: .CoverPic)
    }
    
    func upload(image: UIImage, taskType: PhotoUploadOperation.TaskType) -> RACSignal {
        let subject = RACReplaySubject()
        let upload = PhotoUploadOperation(meteor: meteor, image: image, taskType: taskType)
        upload.completionBlock = {
            switch upload.result! {
            case .Success:
                subject.sendCompleted()
            case .Error(let error):
                subject.sendError(error)
            case .Cancelled:
                subject.sendError(nil)
            }
        }
        operationQueue.addOperation(upload)
        return subject.deliverOnMainThread()
    }

}