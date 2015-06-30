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

public class MessageViewModel {
    
    public let message: Message?
    public let sender: User?
    public let formattedDate: Dynamic<String>
    public let formattedStatus: Dynamic<String>
    public let videoURL: Dynamic<NSURL?>
    
    public init(message: Message) {
        self.message = message
        sender = message.sender
        videoURL = message.video?.URL ?? Dynamic(nil)
        formattedDate = reduce(message.dynCreatedAt, CurrentDate) {
            Formatters.formatRelativeDate($0, relativeTo: $1) ?? ""
        }
        formattedStatus = reduce(message.dynStatus, message.dynExpiresAt, CurrentDate) { status, expiresAt, now in
            if let status = status {
                switch status {
                case .Sending: return "sending..."
                case .Sent: return "sent"
                case .Delivered: return "delivered"
                case .Expired: return "expired"
                case .Opened:
                    if let timeLeft = expiresAt?.timeIntervalSinceDate(now) {
                        return "opened. expires in \(Int(ceil(timeLeft))) seconds"
                    } else {
                        return "opened"
                    }
                }
            }
            return ""
        }
    }
}
