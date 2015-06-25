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

// TODO: Implement this using RAC, make it not a global constant?
let CurrentDate: Dynamic<NSDate> = {
    let dynamic = Dynamic(NSDate())
    RACSignal.interval(0.25, onScheduler: RACScheduler.mainThreadScheduler()).subscribeNext { date in
        dynamic.value = date as! NSDate
    }
    return dynamic
}()

public class MessageViewModel {
    
    public let message: Message?
    public let sender: User?
    public let formattedDate: Dynamic<String>
    public let formattedStatus: Dynamic<String>
    public let videoURL: Dynamic<NSURL?>
    
    public init(message: Message) {
        self.message = message
        sender = message.sender
        videoURL = message.video!.URL
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
