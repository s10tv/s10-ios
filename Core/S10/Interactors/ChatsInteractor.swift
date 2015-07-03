//
//  ChatsInteractor.swift
//  Taylr
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import CoreData
import Bond

public class ChatsInteractor {
    public let connectionViewModels: DynamicArray<ConversationInteractor>
    
    public init() {
        connectionViewModels = Connection
            .by("\(ConnectionKeys.otherUser) != nil")
            .sorted(by: ConnectionKeys.updatedAt.rawValue, ascending: false)
            .results(Connection).map { ConversationInteractor(recipient: $0.otherUser!) }
    }
}