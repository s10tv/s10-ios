//
//  ProfileViewModel.swift
//  S10
//
//  Created by Tony Xiao on 6/27/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import CoreData
import Bond

public class ProfileViewModel {
    let frc: NSFetchedResultsController
    let meteor: MeteorService
    var servicesSubscription: METSubscription?
    var activitiesSubscription: METSubscription?
    public let user: User
    public let activities: DynamicArray<ActivityViewModel>
    
    public init(meteor: MeteorService, user: User) {
        self.meteor = meteor
        self.user = user
        frc = Activity
            .by(ActivityKeys.user, value: user)
            .sorted(by: ActivityKeys.timestamp.rawValue, ascending: false).frc()
        activities = frc.dynSections[0].map { (o, _) in ActivityViewModel(o as! Activity) }
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