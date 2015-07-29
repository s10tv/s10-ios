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

public struct MessageViewModel {
    
    let message: Message
    public let formattedDate: PropertyOf<String>
    public let localVideoURL: NSURL
    public let messageId: String
    public let videoDuration: NSTimeInterval
    
    init(message: Message, localVideoURL: NSURL) {
        self.message = message
        self.localVideoURL = localVideoURL
        messageId = message.documentID!
        formattedDate = relativeTime(message.createdAt)
        videoDuration = 6 // WRONG!!!!
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