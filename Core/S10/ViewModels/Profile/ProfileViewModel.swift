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

public struct ProfileViewModel {
    let meteor: MeteorService
    let taskService: TaskService
    let user: User
    let subscription: MeteorSubscription
    let results: FetchedResultsArray<Activity>
    let predicate: PropertyOf<NSPredicate>
    
    public let coverVM: DynamicArray<ProfileCoverViewModel>
    public let infoVM: DynamicArray<ProfileInfoViewModel>
    public let activities: DynamicArray<ActivityViewModel>
    
    init(meteor: MeteorService, taskService: TaskService, user: User) {
        self.meteor = meteor
        self.taskService = taskService
        self.user = user
        let cvm = ProfileCoverViewModel(user: user)
        subscription = meteor.subscribe("activities", user)
        coverVM = DynamicArray([cvm])
        infoVM = toBondDynamicArray(cvm.selectedProfile |> map { _ in
return [TaylrProfileInfoViewModel(user: user)]
//            $0.profile.map { [ConnectedProfileInfoViewModel(profile: $0)] }
//                ?? [TaylrProfileInfoViewModel(user: user)]
        })
        results = Activity
            .by(supportedActivitiesByUser(user))
            .sorted(by: ActivityKeys.timestamp.rawValue, ascending: false)
            .fetchedResultsController(nil)
            .results(Activity)
        activities = results.map(viewModelForActivity)
        predicate = cvm.selectedProfile |> map {
            ($0.profile?.id).map {
                NSPredicate(format: "%K == %@", ActivityKeys.profileId.rawValue, $0)
            } ?? NSPredicate(format: "%K == %@", ActivityKeys.user.rawValue, user)
        }
        toBondDynamic(predicate) ->> results.predicateBond
    }
    
    public func conversationVM() -> ConversationViewModel {
        return ConversationViewModel(meteor: meteor, taskService: taskService, recipient: user)
    }
}

public struct ProfileCoverViewModel {
    public let firstName: PropertyOf<String>
    public let lastName: PropertyOf<String>
    public let proximity: PropertyOf<String>
    public let avatar: PropertyOf<Image?>
    public let cover: PropertyOf<Image?>
    public let selectors: DynamicArray<ProfileSelectorViewModel>
    public let selectedProfile: MutableProperty<ProfileSelectorViewModel>
    
    init(user: User) {
        firstName = user.pFirstName()
        lastName = user.pLastName()
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
        proximity = PropertyOf("", combineLatest(
            user.dyn(.distance).optional(Double).producer,
            user.dyn(.lastActive).optional(NSDate).producer,
            CurrentTime.producer
        ) |> map {
            let distance = $0.map { Formatters.formatDistance($0) + " away" } ?? ""
            let lastActive = Formatters.formatRelativeDate($1, relativeTo: $2) ?? ""
            return "\(distance), \(lastActive)"
        })
        selectedProfile = MutableProperty(selectors[0])
    }
    
    public func selectProfileAtIndex(index: Int) {
        selectedProfile.value = selectors[index]
    }
}

public struct ProfileSelectorViewModel {
    let profile: User.ConnectedProfile?
    public let icon: Image
    //    let altImage: Image?
    public let color: UIColor
    
    init(profile: User.ConnectedProfile?) {
        self.profile = profile
        icon = profile?.icon ?? Image(UIImage(named: "ic-all")!)
        color = profile?.themeColor ?? UIColor(red: 0.290, green: 0.078, blue: 0.549, alpha: 1.000) // brandPurple
    }
}
