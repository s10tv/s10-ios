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
    public let senderInfo: String
    public let messageInfo: String
    
    init(meteor: MeteorService, message: Message, localVideoURL: NSURL) {
        self.message = message
        self.localVideoURL = localVideoURL
        outgoing = (message.sender.documentID == meteor.userId.value)
        messageId = message.documentID!
        formattedDate = relativeTime(message.createdAt)
        videoDuration = message.video.duration ?? 0
        video = message.video
        senderInfo = message.sender.pDisplayName().value
        let status = (message.status == .Sent) ? "Sent" : "Opened"
        messageInfo = "\(formattedDate.value) - \(status)"
    }
}

extension MessageViewModel {
    public var uniqueId: String { return messageId }
    public var url: NSURL { return localVideoURL }
    public var duration: NSTimeInterval { return videoDuration }
    public var thumbnail: Image? { return video.thumbnail }
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