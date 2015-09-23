//
//  ProfileViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/25/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Bond
import Box

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
    let results: FetchedResultsArray<Activity>
    let predicate: PropertyOf<NSPredicate>
    
    public let cvm: ProfileCoverViewModel
    public let coverVM: DynamicArray<ProfileCoverViewModel>
    public let infoVM: DynamicArray<ProfileInfoViewModel>
    public let activities: DynamicArray<ActivityViewModel>
    public let showMoreOptions: Bool
    public let allowMessage: Bool
    public let timeRemaining: PropertyOf<String>
    
    init(meteor: MeteorService, taskService: TaskService, user: User, timeRemaining: PropertyOf<String>? = nil) {
        self.meteor = meteor
        self.taskService = taskService
        self.user = user
        self.timeRemaining = timeRemaining ?? PropertyOf("")
        allowMessage = timeRemaining != nil
        showMoreOptions = meteor.user.value != user
        cvm = ProfileCoverViewModel(meteor: meteor, user: user)
        subscription = meteor.subscribe("activities", user)
        coverVM = DynamicArray([cvm])
        infoVM = toBondDynamicArray(cvm.selectedProfile |> map {
            $0.profile.map { [ConnectedProfileInfoViewModel(profile: $0)] }
                ?? [TaylrProfileInfoViewModel(meteor: meteor, user: user)]
        })
        results = Activity
            .by(supportedActivitiesByUser(user))
            .sorted(by: ActivityKeys.timestamp.rawValue, ascending: false)
            .fetchedResultsController(nil)
            .results(Activity)
        activities = results.map(viewModelForActivity)
        predicate = cvm.selectedProfile |> map {
            $0.profile.map(supportedActivitiesByProfile) ?? supportedActivitiesByUser(user)
        }
        toBondDynamic(predicate) ->> results.predicateBond
    }
    
    public func reportUser(reason: String) {
        meteor.reportUser(user, reason: reason)
    }
    
    public func blockUser() {
        meteor.blockUser(user)
    }
    
    public func conversationVM() -> ConversationViewModel {
        return ConversationViewModel(meteor: meteor, taskService: taskService, recipient: user)
    }
}

public struct ProfileCoverViewModel {
    public let firstName: PropertyOf<String>
    public let lastName: PropertyOf<String>
    public let displayName : PropertyOf<String>
    public let avatar: PropertyOf<Image?>
    public let cover: PropertyOf<Image?>
    public let selectors: DynamicArray<ProfileSelectorViewModel>
    public let selectedProfile: MutableProperty<ProfileSelectorViewModel>
    
    init(meteor: MeteorService, user: User) {
        firstName = user.pFirstName()
        lastName = user.pLastName()
        displayName = user.pDisplayName()
        avatar = user.pAvatar()
        cover = user.pCover()
        selectors = toBondDynamicArray(
            user.pConnectedProfiles() |> map {
                var selectors = [ProfileSelectorViewModel(profile: nil)]
                selectors.extend($0.map {
                    ProfileSelectorViewModel(profile: $0)
                })
                return selectors
            }
        )
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
