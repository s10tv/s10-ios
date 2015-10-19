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

internal let CurrentTime: PropertyOf<NSDate> = PropertyOf(NSDate()) {
    timer(1, onScheduler: QueueScheduler.mainQueueScheduler)
}

internal func relativeTime(date: NSDate?) -> PropertyOf<String> {
    return CurrentTime.map {
        Formatters.formatRelativeDate(date, relativeTo: $0) ?? ""
    }
}

let CabinRegular11 = UIFont(name: "Cabin-Regular", size: 11)!
let CabinBold11 = UIFont(name: "Cabin-Bold", size: 11)!

public struct Formatters {
    private static let height : NSLengthFormatter = {
        let formatter = NSLengthFormatter()
        formatter.forPersonHeightUse = true
        formatter.unitStyle = .Short
        formatter.numberFormatter.maximumFractionDigits = 0
        return formatter
    }()
    private static let timeInterval: TTTTimeIntervalFormatter = {
        let formatter = TTTTimeIntervalFormatter()
        formatter.presentTimeIntervalMargin = 60
        formatter.usesIdiomaticDeicticExpressions = true
        formatter.usesAbbreviatedCalendarUnits = true
        return formatter
    }()
    private static let distanceFormatter: NSLengthFormatter = {
        let formatter = NSLengthFormatter()
        formatter.unitStyle = .Medium
        formatter.numberFormatter.maximumFractionDigits = 0
        return formatter
    }()
    
    public static func cleanString(str: String?) -> String {
        return str.map {
            $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        } ?? ""
    }
    
    public static func formatHeight(heightInCm: Int) -> String {
        return height.stringFromMeters(Double(heightInCm) / 100)
    }
    
    public static func formatInterval(date: NSDate?, relativeTo: NSDate = NSDate()) -> String? {
        return date.map { timeInterval.stringForTimeIntervalFromDate(NSDate(), toDate: $0) }
    }
    
    public static func formatFullname(firstName: String?, lastName: String?, gradYear: String?) -> String {
        let name = String(format: "%@ %@", firstName ?? "", lastName ?? "").nonBlank() ?? ""
        return gradYear.map { "\(name) \($0)" } ?? name
    }
    
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
    
    public static func formateDaysAgo(date: NSDate) -> String {
        let cal = NSCalendar.currentCalendar()
        let days = cal.components(.Day, fromDate: date, toDate: NSDate(), options: []).day
        switch days {
        case 0: return "Today"
        case 1: return "Yesterday"
        default: return "\(days) days ago"
        }
    }
    
    public static func formatDistance(distance: Double) -> String {
        // TODO: Security concern?
        if distance < 1.0 {
            return "< 1 mi"
        }
        return distanceFormatter.stringFromMeters(distance * 1609.34)
    }
    
    // MARK: - Date Time Formatter
    
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
    
    public static func attributedStringForDisplayOfRecipientStatus(recipientStatus: [NSObject: AnyObject], ctx: Context) -> NSAttributedString {
        let statuses = recipientStatus
            .filter { key, _ in key != ctx.currentUserId }
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
                let suffix = readCount > 1 ? "Participants" : "Participant"
                statusString = "Read by \(readCount) \(suffix)"
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
        return NSAttributedString(string: statusString, attributes: [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: CabinBold11
        ])
    }
}


extension LYRRecipientStatus: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .Invalid: return "Not Sent"
        case .Pending: return "Pending"
        case .Sent: return "Sent"
        case .Delivered: return "Delivered"
        case .Read: return "Read"
        }
    }
    
}