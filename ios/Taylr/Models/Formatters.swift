//
//  Formatters.swift
//  Taylr
//
//  Created by Tony Xiao on 4/17/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import FormatterKit
import LayerKit
import DateTools
import ReactiveCocoa

let CabinRegular11 = UIFont(name: "Cabin-Regular", size: 11)!
let CabinBold11 = UIFont(name: "Cabin-Bold", size: 11)!

// TODO: Move as much of this into JSLand as possible, once we figure out how...

public struct Formatters {
    
    // MARK: - Formatting message sent date
    
    public enum DateProximity {
        case Today, Yesterday, Week, Year, Other
    }
    
    public static func proximityToDate(date: NSDate) -> DateProximity {
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let calendarUnits: NSCalendarUnit = [.Era, .Year, .WeekOfMonth, .Month, .Day]
        let dateComponents = calendar.components(calendarUnits, fromDate: date)
        let todayComponents = calendar.components(calendarUnits, fromDate: now)
        if dateComponents.day == todayComponents.day &&
            dateComponents.month == todayComponents.month &&
            dateComponents.year == todayComponents.year &&
            dateComponents.era == todayComponents.era {
            return .Today
        }
        
        let componentsToYesterday = NSDateComponents()
        componentsToYesterday.day = -1
        let yesterday = calendar.dateByAddingComponents(componentsToYesterday, toDate: now, options: [])!
        let yesterdayComponents = calendar.components(calendarUnits, fromDate: yesterday)
        if dateComponents.day == yesterdayComponents.day &&
            dateComponents.month == yesterdayComponents.month &&
            dateComponents.year == yesterdayComponents.year &&
            dateComponents.era == yesterdayComponents.era {
            return .Yesterday
        }
        
        if dateComponents.weekOfMonth == todayComponents.weekOfMonth &&
        dateComponents.month == todayComponents.month &&
        dateComponents.year == todayComponents.year &&
            dateComponents.era == todayComponents.era {
            return .Week
        }
        
        if dateComponents.year == todayComponents.year &&
            dateComponents.era == todayComponents.era {
            return .Year
        }
        
        return .Other
    }
    
    public static func formatMessageDate(date: NSDate) -> (dateString: String, timeString: String) {
        var dateFormatter: NSDateFormatter!
        switch proximityToDate(date) {
        case .Today, .Yesterday:
            dateFormatter = relativeDate
        case .Week:
            dateFormatter = dayOfWeekDate
        case .Year:
            dateFormatter = thisYearDate
        case .Other:
            dateFormatter = defaultDate
        }
        let dateString = dateFormatter.stringFromDate(date)
        let timeString = shortTime.stringFromDate(date)
        return (dateString, timeString)
    }
    
    private static let shortTime: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    
    private static let dayOfWeekDate: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE" // Tuesday
        return formatter
    }()
    
    private static let relativeDate: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    private static let thisYearDate: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "E, MM dd," // Sat, Nov 29,
        return formatter
    }()
    
    private static let defaultDate: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM dd, yyyy," // Nov 29, 2013,
        return formatter
    }()
    
    // MARK: - Attributed String Formatter
    // Formatting borrowed kindly from
    // https://github.com/layerhq/Atlas-Messenger-iOS/blob/master/Code/Controllers/ATLMConversationViewController.m#L29-L370
    
    public static func attributedStringForDate(date: NSDate) -> NSAttributedString {
        let (dateString, timeString) = formatMessageDate(date)
        let dateTimeString = "\(dateString) \(timeString)"
        let attrString = NSMutableAttributedString(string: dateTimeString)
        attrString.addAttributes([
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: CabinRegular11
        ], range: NSMakeRange(0, dateTimeString.length))
        attrString.addAttribute(NSFontAttributeName, value: CabinBold11,
            range: NSMakeRange(0, dateString.length))
        return attrString
    }
    
    static func stringForDisplayOfRecipientStatus(recipientStatus: [NSObject: AnyObject], currentUserId: String) -> String {
        let statuses = recipientStatus
            .filter { key, _ in key != currentUserId }
            .map { ($0 as! String, LYRRecipientStatus(rawValue: $1 as! Int)!) }
        
        var statusString: String!
        if statuses.count > 1 {
            var readCount = 0
            var delivered = false
            var sent = false
            var pending = false
            for (_, status) in statuses {
                switch status {
                case .Invalid:
                    break
                case .Pending:
                    pending = true
                case .Sent:
                    sent = true
                case .Delivered:
                    delivered = true
                case .Read:
                    readCount++
                }
            }
            if readCount > 0 {
                let suffix = readCount > 1 ? "participants" : "participant"
                statusString = "Opened by \(readCount) \(suffix)"
            } else if pending {
                statusString = "Pending"
            } else if delivered {
                statusString = "Delivered"
            } else if sent {
                statusString = "Sent"
            }
        } else {
            statusString = Array(statuses.values).first?.description ?? ""
        }
        return statusString
    }
    
    static func attributedStringForDisplayOfRecipientStatus(recipientStatus: [NSObject: AnyObject], currentUserId: String) -> NSAttributedString {
        return NSAttributedString(string: stringForDisplayOfRecipientStatus(recipientStatus, currentUserId: currentUserId), attributes: [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: CabinBold11
        ])
    }
    
    // MARK: - Formatting Conversation Status
    
    private static let timeInterval: TTTTimeIntervalFormatter = {
        let formatter = TTTTimeIntervalFormatter()
        formatter.presentTimeIntervalMargin = 60
        formatter.usesIdiomaticDeicticExpressions = true
        formatter.usesAbbreviatedCalendarUnits = true
        return formatter
    }()
    
    public static func formatRelativeDate(date: NSDate?, relativeTo: NSDate = NSDate()) -> String? {
        if let date = date {
            let interval = relativeTo.timeIntervalSinceDate(date)
            let secondsPerDay: Double = 24 * 60 * 60
            
            if interval > secondsPerDay * 365 {
                return date.formattedDateWithFormat("MMM d, yyyy") // 13 Jun, 2015
            } else if interval > secondsPerDay * 7 {
                return date.formattedDateWithFormat("MMM d") // 13 Jun
            } else if interval > secondsPerDay * 2 {
                return date.formattedDateWithFormat("EEEE h:mma") // Saturday 1:05PM
            } else if interval > secondsPerDay {
                let timeText = date.formattedDateWithFormat("h:mma")
                return "Yesterday \(timeText)"
            }
            return timeInterval.stringForTimeIntervalFromDate(NSDate(), toDate: date)
        }
        return nil
    }
    public static func readableStatusWithDate(msg: LYRMessage, currentUserId: String) -> String? {
        let sentLast = msg.sender.userID == currentUserId
        let date: NSDate? = sentLast ? msg.sentAt : msg.receivedAt
        let formattedDate = date.flatMap { Formatters.formatRelativeDate($0) } ?? ""
        let statuses = msg.recipientStatusByUserID
            .filter { key, _ in key != currentUserId }
            .map { LYRRecipientStatus(rawValue: $1 as! Int)! }
        if sentLast == true {
            if let status = statuses.first {
                switch status {
                case .Invalid: return "Sending..."
                case .Pending: return "Sending..."
                case .Sent: return "Sent \(formattedDate)"
                case .Delivered: return "Delivered \(formattedDate)"
                case .Read: return "Opened \(formattedDate)"
                }
            }
        } else {
            return "Received \(formattedDate)"
        }
        return nil
    }

}
