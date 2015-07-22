//
//  MeInteractor.swift
//  S10
//
//  Created by Tony Xiao on 6/30/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Bond
import Meteor
import ReactiveCocoa

public class MeInteractor {
    let meteor: MeteorService
    let taskService: TaskService
    let servicesSubscription: METSubscription
    
    public let currentUser: User
    public let avatarURL: Dynamic<NSURL?>
    public let displayName: Dynamic<String>
    public let username: Dynamic<String>
    public let linkedServices: DynamicArray<ServiceViewModel>
    public let serviceTypes: FetchedResultsArray<ServiceType>
    
    public let inviteeFirstName = MutableProperty("")
    public let inviteeLastName = MutableProperty("")
    public let inviteeEmailOrPhone = MutableProperty("")
    
    public init(meteor: MeteorService, taskService: TaskService, currentUser: User) {
        self.meteor = meteor
        self.taskService = taskService
        self.currentUser = currentUser
        avatarURL = currentUser.dynAvatar.map { $0?.url }
        displayName = currentUser.displayName
        username = currentUser.dynUsername.map { $0 ?? "" }
        linkedServices = Service
            .by(ServiceKeys.user, value: currentUser)
//            .sorted(by: ServiceKeys.serviceType.rawValue, ascending: true) // Not sortable
            .results(Service).map { ServiceViewModel($0) }
        serviceTypes = ServiceType.all().results(ServiceType)
        
        servicesSubscription = meteor.subscribeServices(currentUser)
    }

    public func sendInvite(videoURL: NSURL) -> RACFuture<(), NSError> {
        let promise = RACPromise<(), NSError>()
        if self.inviteeEmailOrPhone.value.isEmpty {
            promise.failure(NSError())
            return promise.future
        }
        return taskService.invite(inviteeEmailOrPhone.value,
            localVideoURL: videoURL,
            firstName: inviteeFirstName.value,
            lastName: inviteeLastName.value)
    }
    
    deinit {
        meteor.unsubscribe(servicesSubscription)
    }
}