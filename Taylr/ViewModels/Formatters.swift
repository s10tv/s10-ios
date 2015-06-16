//
//  Formatters.swift
//  Taylr
//
//  Created by Tony Xiao on 4/17/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation

struct Formatters {
    static let height : NSLengthFormatter = {
        let formatter = NSLengthFormatter()
        formatter.forPersonHeightUse = true
        formatter.unitStyle = .Short
        formatter.numberFormatter.maximumFractionDigits = 0
        return formatter
    }()
//    static let time = JSQMessagesTimestampFormatter.sharedFormatter()
    
    static func formatHeight(heightInCm: Int) -> String {
        return height.stringFromMeters(Double(heightInCm) / 100)
    }
    
    // TODO: Move formatting into localizable
//    static func formatRelativeDate(date: NSDate) -> String {
//        return "Seen \(time.relativeDateForDate(date).lowercaseString) at \(time.timeForDate(date).lowercaseString)"
//    }
    
    static func formatGenderPref(pref: String) -> String {
        if pref == "both" { return "men and women" }
        return pref
    }
}