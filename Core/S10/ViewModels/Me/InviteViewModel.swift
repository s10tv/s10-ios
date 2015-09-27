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
    
    public let firstName = MutableProperty<String?>("")
    public let lastName = MutableProperty<String?>("")
    public let emailOrPhone = MutableProperty<String?>("")
    
    public init(meteor: MeteorService, taskService: TaskService) {
        self.meteor = meteor
        self.taskService = taskService
    }
    
    public func validateInvite() -> ErrorAlert? {
        if firstName.value?.nonBlank() == nil {
            return ErrorAlert(title: "Invalid Invite", message: "First name is required")
        } else if emailOrPhone.value?.nonBlank() == nil {
            return ErrorAlert(title: "Invalid Invite", message: "Email or phone is required")
        }
        return nil
    }
    
    // TODO: Turn into AlertableError
    public func sendInvite(videoURL: NSURL, thumbnail: UIImage) -> Future<(), NSError> {
        print("Will send invite with video \(videoURL)")
        return taskService.invite(emailOrPhone.value!,
            localVideoURL: videoURL,
            thumbnail: thumbnail,
            firstName: firstName.value,
            lastName: lastName.value
        ).onSuccess {
                self.firstName.value = ""
                self.lastName.value = ""
                self.emailOrPhone.value = ""
        }.deliverOn(UIScheduler())
    }
}