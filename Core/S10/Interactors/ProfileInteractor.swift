//
//  ProfileInteractor.swift
//  S10
//
//  Created by Tony Xiao on 6/27/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import CoreData
import Bond

public class ProfileInteractor {
    let meteor: MeteorService
    var servicesSubscription: METSubscription?
    var activitiesSubscription: METSubscription?
    public let user: User
    public let services: DynamicArray<ServiceViewModel>
    public let activities: DynamicArray<ActivityViewModel>
    public let avatarURL: Dynamic<NSURL?>
    public let coverURL: Dynamic<NSURL?>
    public let displayName: Dynamic<String>
    public let username: Dynamic<String>
    public let distance: Dynamic<String>
    public let lastActive: Dynamic<String>
    public let about: Dynamic<String>
    
    public init(meteor: MeteorService, user: User) {
        self.meteor = meteor
        self.user = user
        services = Service
            .by(ServiceKeys.user, value: user)
            .sorted(by: ServiceKeys.serviceType.rawValue, ascending: true)
            .results(Service).map { ServiceViewModel($0) }
        activities = Activity
            .by(ActivityKeys.user, value: user)
            .sorted(by: ActivityKeys.timestamp.rawValue, ascending: false)
            .results(Activity).map { ActivityViewModel($0) }
        avatarURL = user.dynAvatar.map { $0?.url }
        coverURL  = user.dynCover.map { $0?.url }
        displayName = user.displayName
        username = user.dynUsername.map { $0 ?? "" }
        distance = user.dynDistance.map { $0.map { Formatters.formatDistance($0) + " away" } ?? "" }
        lastActive = reduce(user.dynLastActive, CurrentDate) {
            Formatters.formatRelativeDate($0, relativeTo: $1) ?? ""
        }
        about = user.dynAbout.map { $0 ?? "" }
        loadProfile()
    }
    
    public func loadProfile() {
        if servicesSubscription == nil {
            servicesSubscription = meteor.subscribeServices(user)
        }
        if activitiesSubscription == nil {
            activitiesSubscription = meteor.subscribeActivities(user)
        }
    }
    
    public func unloadProfile() {
        meteor.unsubscribe(servicesSubscription)
        meteor.unsubscribe(activitiesSubscription)
        servicesSubscription = nil
        activitiesSubscription = nil
    }
    
    deinit {
        unloadProfile()
    }
}