//
//  InviteViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/22/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Meteor
import ReactiveCocoa

public struct InviteViewModel {
    let meteor: MeteorService
    let taskService: TaskService
    
    public let firstName = MutableProperty("")
    public let lastName = MutableProperty("")
    public let emailOrPhone = MutableProperty("")
    
    public init(meteor: MeteorService, taskService: TaskService) {
        self.meteor = meteor
        self.taskService = taskService
    }
    
    public func sendInvite(videoURL: NSURL) -> RACFuture<(), NSError> {
        let promise = RACPromise<(), NSError>()
        if self.emailOrPhone.value.isEmpty {
            promise.failure(NSError())
            return promise.future
        }
        let future = taskService.invite(emailOrPhone.value,
            localVideoURL: videoURL,
            firstName: firstName.value,
            lastName: lastName.value)
        future |> deliverOn(UIScheduler()) |> onSuccess {
            self.firstName.value = ""
            self.lastName.value = ""
            self.emailOrPhone.value = ""
        }
        return future
    }
}