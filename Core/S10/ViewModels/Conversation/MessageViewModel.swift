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
    public let messageId: String
    public let formattedDate: PropertyOf<String>
    public let unread: PropertyOf<Bool>
    public let outgoing: Bool
    public let senderInfo: String
    public let messageInfo: PropertyOf<String>
    
    // Video Specific
    public let video: Video
    public let url: NSURL
    public let duration: NSTimeInterval
    public let thumbnail: Image?
    
    init(meteor: MeteorService, message: Message, localVideoURL: NSURL) {
        let sentByMe = (message.sender.documentID == meteor.userId.value)
        self.message = message
        url = localVideoURL
        outgoing = sentByMe
        unread = message.pStatus().map { $0 == .Sent && !sentByMe }
        messageId = message.documentID!
        formattedDate = relativeTime(message.createdAt)
        duration = message.video.duration ?? 0
        video = message.video
        senderInfo = message.sender.pDisplayName().value
        thumbnail = message.video.thumbnail
        messageInfo = message.pStatus().map { $0 == .Sent ? "Sent" : "Opened" }
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
    return lhs.messageId == rhs.messageId
}