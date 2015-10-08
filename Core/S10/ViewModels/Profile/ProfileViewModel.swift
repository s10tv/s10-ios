//
//  ProfileViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/25/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

private func supportedActivitiesByUser(user: User) -> NSPredicate {
    let supportedTypes: [Activity.ContentType] = [.Image, .Text]
    return NSPredicate(format: "%K == %@ && %K IN %@",
        ActivityKeys.user.rawValue, user,
        ActivityKeys.type_.rawValue, supportedTypes.map { $0.rawValue })
}

private func supportedActivitiesByProfile(profile: User.ConnectedProfile) -> NSPredicate {
    let supportedTypes: [Activity.ContentType] = [.Image, .Text]
    return NSPredicate(format: "%K == %@ && %K IN %@",
        ActivityKeys.profileId.rawValue, profile.id,
        ActivityKeys.type_.rawValue, supportedTypes.map { $0.rawValue })
}

public struct ProfileViewModel {
    let meteor: MeteorService
    let taskService: TaskService
    let user: User
    let subscription: MeteorSubscription
    
    public let coverVM: ProfileCoverViewModel
    public let infoVM: PropertyOf<ProfileInfoViewModel>
    public let activities: FetchedResultsArray<ActivityViewModel>
    public let showMoreOptions: Bool
    public let allowMessage: Bool
    public let timeRemaining: ProducerProperty<String>
    
    init(meteor: MeteorService, taskService: TaskService, user: User, timeRemaining: ProducerProperty<String>? = nil) {
        self.meteor = meteor
        self.taskService = taskService
        self.user = user
        self.timeRemaining = timeRemaining ?? ProducerProperty(SignalProducer(value: ""))
        allowMessage = timeRemaining != nil
        showMoreOptions = meteor.user.value != user
        subscription = meteor.subscribe("activities", user)
        coverVM = ProfileCoverViewModel(meteor: meteor, user: user)
        infoVM = coverVM.selectedProfile.map {
            if let connectedProfile = $0.profile {
                return ConnectedProfileInfoViewModel(profile: connectedProfile)
            }
            return TaylrProfileInfoViewModel(meteor: meteor, user: user)
        }
        activities = Activity
            .by(supportedActivitiesByUser(user))
            .sorted(by: ActivityKeys.timestamp.rawValue, ascending: false)
            .results(viewModelForActivity)
        // NOTE: Cannot use <~ with map on right hand side due to immediate memory mgmt release issue
        activities.predicate <~ coverVM.selectedProfile.producer.skip(1).map {
            $0.profile.map(supportedActivitiesByProfile) ?? supportedActivitiesByUser(user)
        }
    }
    
    public func reportUser(reason: String) {
        meteor.reportUser(user, reason: reason)
    }
    
    public func blockUser() {
        meteor.blockUser(user)
    }
    
    public func conversationVM() -> ConversationViewModel {
        return ConversationViewModel(meteor: meteor, taskService: taskService, conversation: .User(user))
    }
}

public struct ProfileCoverViewModel {
    public let firstName: PropertyOf<String>
    public let lastName: PropertyOf<String>
    public let displayName : ProducerProperty<String>
    public let avatar: PropertyOf<Image?>
    public let cover: PropertyOf<Image?>
    public let selectors: ArrayProperty<ProfileSelectorViewModel>
    public let selectedProfile: MutableProperty<ProfileSelectorViewModel>
    
    init(meteor: MeteorService, user: User) {
        firstName = user.pFirstName()
        lastName = user.pLastName()
        displayName = user.pDisplayName()
        avatar = user.pAvatar()
        cover = user.pCover()
        selectors = user.pConnectedProfiles().map { profiles -> [ProfileSelectorViewModel] in
            var selectors = [ProfileSelectorViewModel(profile: nil)]
            selectors.appendContentsOf(profiles.map {
                ProfileSelectorViewModel(profile: $0)
            })
            return selectors
        }.array()
        selectedProfile = MutableProperty(selectors[0])
    }
    
    public func selectProfileAtIndex(index: Int) {
        selectedProfile.value = selectors[index]
    }
}

public struct ProfileSelectorViewModel {
    let profile: User.ConnectedProfile?
    public let icon: Image
    public let altIcon: Image
    public let color: UIColor
    public let integrationName: String
    
    init(profile: User.ConnectedProfile?) {
        self.profile = profile
        integrationName = profile?.integrationName ?? ""
        icon = profile?.icon ?? Image(UIImage(named: "ic-all")!)
        altIcon = profile?.altIcon ?? Image(UIImage(named: "ic-all-gray")!)
        color = profile?.themeColor ?? UIColor(red: 0.290, green: 0.078, blue: 0.549, alpha: 1.000) // brandPurple
    }
}
