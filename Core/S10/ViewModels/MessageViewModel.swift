//
//  MessageViewModel.swift
//  S10
//
//  Created by Tony Xiao on 6/21/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation

public class MessageViewModel {
    public var videoURL: NSURL?
    public var sender: User?
    public var createdAt: NSDate?
    public var expiresAt: NSDate?
    public var status: Message.Status?
    
    public init(message: Message) {
        videoURL = message.video?.URL
        sender = message.sender
        createdAt = message.createdAt
        expiresAt = message.expiresAt
        status = message.statusEnum
    }
    
    public func statusText() -> String {
        switch status! {
        case .Sending: return "sending..."
        case .Sent: return "sent"
        case .Delivered: return "delivered"
        case .Opened:
            let seconds = Int(ceil(expiresAt!.timeIntervalSinceNow))
            return "opened. expires in \(seconds) seconds"
        case .Expired: return "expired"
        }
    }
    
    func isOrderedBefore(other: MessageViewModel) -> Bool {
        if let thisDate = createdAt,
            let otherDate = other.createdAt {
            return thisDate < otherDate
        }
        return true
    }
}

public func ==(lhs: MessageViewModel, rhs: MessageViewModel) -> Bool {
    return lhs === rhs
}
extension MessageViewModel : Equatable {
    
}