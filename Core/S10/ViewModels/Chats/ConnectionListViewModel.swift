//
//  ConnectionListViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/25/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Bond

public struct ConnectionListViewModel {
    let meteor: MeteorService
    public let contactsConnections: DynamicArray<ContactConnectionViewModel>
    public let newConnections: DynamicArray<NewConnectionViewModel>
    
    public init(meteor: MeteorService) {
        self.meteor = meteor
        contactsConnections = Connection
            .by("\(ConnectionKeys.otherUser) != nil && \(ConnectionKeys.cold) == false")
            .sorted(by: ConnectionKeys.updatedAt.rawValue, ascending: false)
            .results(Connection)
            .map { ContactConnectionViewModel(connection: $0) }
        newConnections = Connection
            .by("\(ConnectionKeys.otherUser) != nil && \(ConnectionKeys.cold) == true")
            .sorted(by: ConnectionKeys.updatedAt.rawValue, ascending: false)
            .results(Connection)
            .map { NewConnectionViewModel(connection: $0) }
        meteor.subscribe("chats")
    }
}
