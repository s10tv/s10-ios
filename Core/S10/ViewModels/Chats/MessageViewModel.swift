//
//  MessageViewModel.swift
//  S10
//
//  Created by Tony Xiao on 6/21/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import FormatterKit
import ReactiveCocoa
import Bond

public struct MessageViewModel {
    
    let message: Message
    public let formattedDate: PropertyOf<String>
    public let video: Video
    
    init(message: Message) {
        self.message = message
        formattedDate = relativeTime(message.createdAt, interval: 1)
        video = message.video
    }
}

extension MessageViewModel : Printable {
    public var description: String {
        return "MessageViewModel[\(message.documentID!)]"
    }
}

extension MessageViewModel : Equatable {
}

public func ==(lhs: MessageViewModel, rhs: MessageViewModel) -> Bool {
    return lhs.message == rhs.message
}