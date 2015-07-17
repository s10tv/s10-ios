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

public struct LinkableAccount {
    public let type: Service.ServiceType
    public let name: String
    public let icon: UIImage?
}

public class MeInteractor {
    let meteor: MeteorService
    let servicesSubscription: METSubscription
    
    public let currentUser: User
    public let avatarURL: Dynamic<NSURL?>
    public let displayName: Dynamic<String>
    public let username: Dynamic<String>
    public let linkedServices: DynamicArray<ServiceViewModel>
    public let linkableAccounts: [LinkableAccount]
    let tempQueue = NSOperationQueue()
    
    public let inviteeFirstName = MutableProperty("")
    public let inviteeLastName = MutableProperty("")
    public let inviteeEmailOrPhone = MutableProperty("")
    
    public init(meteor: MeteorService, currentUser: User) {
        self.meteor = meteor
        self.currentUser = currentUser
        avatarURL = currentUser.avatarURL
        displayName = currentUser.displayName
        username = currentUser.dynUsername.map { $0 ?? "" }
        linkedServices = Service
            .by(ServiceKeys.user, value: currentUser)
            .sorted(by: ServiceKeys.serviceType.rawValue, ascending: true)
            .results(Service).map { ServiceViewModel($0) }
        linkableAccounts = [
            LinkableAccount(type: .Facebook, name: "Facebook", icon: UIImage(named: "ic-facebook")),
            LinkableAccount(type: .Instagram, name: "Instagram", icon: UIImage(named: "ic-instagram")),
            LinkableAccount(type: .Github, name: "Github", icon: UIImage(named: "ic-github"))
        ]
        servicesSubscription = meteor.subscribeServices(currentUser)
    }

    public func sendInvite(videoURL: NSURL) -> RACFuture<(), NSError> {
        return RACPromise { promise in
            if self.inviteeEmailOrPhone.value.isEmpty {
                promise.failure(NSError())
                return
            }
            // TODO: Invite tasks should be saved to disk and retried until success
            self.tempQueue.addAsyncOperation {
                InviteOperation(meteor: self.meteor,
                    localVideoURL: videoURL,
                    recipientFirstName: self.inviteeFirstName.value,
                    recipientLastName: self.inviteeLastName.value,
                    recipientPhoneOrEmail: self.inviteeEmailOrPhone.value)
            }.onSuccess {
                promise.success()
            }.onFailure {
                promise.failure($0)
            }
        }.future
    }
    
    deinit {
        meteor.unsubscribe(servicesSubscription)
    }
}