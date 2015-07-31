//
//  ConnectionViewModels.swift
//  S10
//
//  Created by Tony Xiao on 7/12/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Bond

extension Connection {
    func dyn(keyPath: ConnectionKeys) -> DynamicProperty {
        return dyn(keyPath.rawValue)
    }
}

public protocol ConnectionViewModel {
    var avatar: PropertyOf<Image?> { get }
    var displayName: PropertyOf<String> { get }
    var busy: PropertyOf<Bool> { get }
}

public struct ContactConnectionViewModel : ConnectionViewModel {
    let connection: Connection
    
    public let avatar: PropertyOf<Image?>
    public let displayName: PropertyOf<String>
    public let statusMessage: PropertyOf<String>
    public let busy: PropertyOf<Bool>
    public let badgeText: PropertyOf<String>
    public let hideRightArrow: PropertyOf<Bool>
    
    init(connection: Connection) {
        self.connection = connection
        let user = connection.otherUser
        avatar = user.pAvatar()
        displayName = user.pDisplayName()
        statusMessage = connection.otherUser.pConversationStatus()
        busy = connection.otherUser.pConversationBusy()
        badgeText = PropertyOf("", combineLatest(
            busy.producer,
            connection.dyn(.unreadCount).force(Int).producer
        ) |> map { busy, unreadCount in
            (busy || unreadCount == 0) ? "" : "\(unreadCount)"
        })
        hideRightArrow = PropertyOf(true, combineLatest(
            busy.producer,
            badgeText.producer
        ) |> map {
            $0 || $1.length > 0
        })
    }
}

public struct NewConnectionViewModel : ConnectionViewModel {
    let connection: Connection
    
    public let avatar: PropertyOf<Image?>
    public let displayName: PropertyOf<String>
    public let displayTime: PropertyOf<String>
    public let tagline: PropertyOf<String>
    public let busy: PropertyOf<Bool>
    public let hidePlayIcon: PropertyOf<Bool>
    public let profileIcons: DynamicArray<Image>

    init(connection: Connection) {
        self.connection = connection
        let user = connection.otherUser
        avatar = user.pAvatar()
        displayName = user.pDisplayName()
        tagline = user.pTagline()
        profileIcons = DynamicArray(user.connectedProfiles.map { $0.icon })
        busy = connection.otherUser.pConversationBusy()
        hidePlayIcon = PropertyOf(true, combineLatest(
            busy.producer,
            connection.dyn(.unreadCount).force(Int).producer
        ) |> map {
            $0 || $1 == 0
        })
        displayTime = relativeTime(connection.updatedAt)
    }
}
