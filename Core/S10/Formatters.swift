//
//  Formatters.swift
//  Taylr
//
//  Created by Tony Xiao on 4/17/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import FormatterKit
import DateTools

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
    
    public static func formatHeight(heightInCm: Int) -> String {
        return height.stringFromMeters(Double(heightInCm) / 100)
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
            } else {
                return timeInterval.stringForTimeIntervalFromDate(NSDate(), toDate: date)
            }
        }
        return nil
    }
    public static func formatDistance(distance: Double) -> String {
        // TODO: Security concern?
        if distance < 1.0 {
            return "< 1 mi"
        }
        return distanceFormatter.stringFromMeters(distance * 1609.34)
    }
}