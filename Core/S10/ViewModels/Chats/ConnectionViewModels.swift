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
    public let unreadCount: PropertyOf<Int>
    public let busy: PropertyOf<Bool>
    
    init(connection: Connection) {
        self.connection = connection
        let user = connection.otherUser
        avatar = user.pAvatar()
        displayName = user.pDisplayName()
        busy = connection.otherUser.pConversationBusy()
        statusMessage = connection.otherUser.pConversationStatus()
        unreadCount = connection.dyn(.unreadCount).force(Int) |> readonly
    }
}

public struct NewConnectionViewModel : ConnectionViewModel {
    let connection: Connection
    
    public let avatar: PropertyOf<Image?>
    public let displayName: PropertyOf<String>
    public let displayTime: PropertyOf<String>
    public let jobTitle: PropertyOf<String>
    public let employer: PropertyOf<String>
    public let busy: PropertyOf<Bool>
    public let profileIcons: DynamicArray<Image>

    init(connection: Connection) {
        self.connection = connection
        let user = connection.otherUser
        avatar = user.pAvatar()
        displayName = user.pDisplayName()
        jobTitle = user.pJobTitle()
        employer = user.pEmployer()
        profileIcons = DynamicArray(user.connectedProfiles.map { $0.icon })
        busy = connection.otherUser.pConversationBusy()
        displayTime = relativeTime(connection.updatedAt)
    }
}
