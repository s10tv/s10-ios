//
//  ConnectionViewModels.swift
//  S10
//
//  Created by Tony Xiao on 7/12/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

extension Connection {
    func dyn(keyPath: ConnectionKeys) -> DynamicProperty {
        return dyn(keyPath.rawValue)
    }
}

public protocol ConnectionViewModel {
    var avatar: PropertyOf<Image?> { get }
    var displayName: ProducerProperty<String> { get }
    var busy: ProducerProperty<Bool> { get }
}

public struct ContactConnectionViewModel : ConnectionViewModel {
    let connection: Connection
    
    public let avatar: PropertyOf<Image?>
    public let displayName: ProducerProperty<String>
    public let statusMessage: ProducerProperty<String>
    public let busy: ProducerProperty<Bool>
    public let badgeText: ProducerProperty<String>
    public let hideRightArrow: ProducerProperty<Bool>
    
    init(connection: Connection) {
        self.connection = connection
        let user = connection.otherUser
        avatar = user.pAvatar()
        displayName = user.pDisplayName()
        statusMessage = connection.otherUser.pConversationStatus()
        busy = connection.otherUser.pConversationBusy()
        badgeText = ProducerProperty(combineLatest(
            busy.producer,
            connection.dyn(.unreadCount).force(Int).producer
        ).map { busy, unreadCount in
                (busy || unreadCount == 0) ? "" : "\(unreadCount)"
        })
        hideRightArrow = ProducerProperty(combineLatest(
            busy.producer,
            badgeText.producer
        ).map {
            $0 || $1.length > 0
        })
    }
}
