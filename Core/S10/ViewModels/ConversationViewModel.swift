//
//  ConversationViewModel.swift
//  S10
//
//  Created by Tony Xiao on 6/21/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Bond

public class ConversationViewModel {
    private let frc: NSFetchedResultsController
    public let messageViewModels: DynamicArray<MessageViewModel>
    public private(set) var recipient: User
    
    public init(connection: Connection) {
        recipient = connection.otherUser!
        frc = connection.fetchMessages(sorted: true)
        messageViewModels = frc.dynSections[0].map { (o, _) in MessageViewModel(message: o as! Message) }
    }
    
    public func indexOfMessage(message: MessageViewModel) -> Int? {
        return find(messageViewModels.value) { $0 === message }
    }
}
