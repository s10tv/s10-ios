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
    public let video: Video
    public var unread: Bool {
        return message.status == .Sent && !outgoing
    }
    public let outgoing: Bool
    
    init(meteor: MeteorService, message: Message, localVideoURL: NSURL) {
        self.message = message
        self.localVideoURL = localVideoURL
        outgoing = (message.sender.documentID == meteor.userId.value)
        messageId = message.documentID!
        formattedDate = relativeTime(message.createdAt)
        videoDuration = message.video.duration ?? 0
        video = message.video
    }
}

extension MessageViewModel : CustomStringConvertible {
    public var description: String {
        return "MessageViewModel[\(message.documentID!)]"
    }
}

extension MessageViewModel : Equatable {
}

public func ==(lhs: MessageViewModel, rhs: MessageViewModel) -> Bool {
    return lhs.message == rhs.message
}