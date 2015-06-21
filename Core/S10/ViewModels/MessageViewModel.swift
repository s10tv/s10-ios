//
//  MessageViewModel.swift
//  S10
//
//  Created by Tony Xiao on 6/21/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import FormatterKit

public class MessageViewModel {
    public let videoURL: NSURL?
    public let sender: User?
    public var dateText: String {
        return Formatters.formatRelativeDate(createdAt!)
    }
    public var statusText: String {
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
    
    let expiresAt: NSDate?
    let createdAt: NSDate?
    let status: Message.Status?
    
    public init(message: Message) {
        videoURL = message.video?.URL
        sender = message.sender
        createdAt = message.createdAt
        expiresAt = message.expiresAt
        status = message.statusEnum
    }
    
    
    
    func isOrderedBefore(other: MessageViewModel) -> Bool {
        if let thisDate = createdAt,
            let otherDate = other.createdAt {
            return thisDate < otherDate
        }
        return true
    }
}
