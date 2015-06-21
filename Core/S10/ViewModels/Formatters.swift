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
        formatter.usesIdiomaticDeicticExpressions = true
        return formatter
    }()
    
    public static func formatHeight(heightInCm: Int) -> String {
        return height.stringFromMeters(Double(heightInCm) / 100)
    }
    
    // TODO: Move formatting into localizable
    static func formatRelativeDate(date: NSDate) -> String {
        let interval = NSDate().timeIntervalSinceDate(date)
        if interval > 60 * 60 * 24 * 7 {
            return date.formattedDateWithStyle(.MediumStyle)
        } else {
            return timeInterval.stringForTimeIntervalFromDate(NSDate(), toDate: date)
        }
    }
    
}