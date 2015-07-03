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
    public let linkedServices: DynamicArray<ServiceViewModel>
    public let linkableAccounts: [LinkableAccount]
    
    public init(meteor: MeteorService, currentUser: User) {
        self.meteor = meteor
        self.currentUser = currentUser
        avatarURL = currentUser.avatarURL
        displayName = currentUser.displayName
        linkedServices = Service
            .by(ServiceKeys.user, value: currentUser)
            .sorted(by: ServiceKeys.serviceType.rawValue, ascending: true)
            .results(Service).map { ServiceViewModel($0) }
        linkableAccounts = [
            LinkableAccount(type: .Facebook, name: "Facebook", icon: UIImage(named: "ic-facebook")),
            LinkableAccount(type: .Instagram, name: "Instagram", icon: UIImage(named: "ic-instagram"))
        ]
        servicesSubscription = meteor.subscribeServices(currentUser)
    }
    
    deinit {
        meteor.unsubscribe(servicesSubscription)
    }
}