//
//  FormatterTests.swift
//  S10
//
//  Created by Tony Xiao on 6/21/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import XCTest
import Nimble

class FormatterTests: XCTestCase {
    
    func testDateFormat() {
        let secondsPerDay: Double = 24 * 60 * 60
        let lastYear = NSDate(timeIntervalSinceNow: -secondsPerDay * 500)
        let thisYear = NSDate(timeIntervalSinceNow: -secondsPerDay * 200)
        let thisWeek = NSDate(timeIntervalSinceNow: -secondsPerDay * 3)
        let yesterday = NSDate(timeIntervalSinceNow: -secondsPerDay - 60)
        let today = NSDate(timeIntervalSinceNow: -secondsPerDay * 0.5)
        let minuteAgo = NSDate(timeIntervalSinceNow: -60 * 5)
        let secondsAgo = NSDate(timeIntervalSinceNow: -5)
        let justNow = NSDate(timeIntervalSinceNow: 0)
        
        println("lastYear \(Formatters.formatRelativeDate(lastYear))")
        println("thisYear \(Formatters.formatRelativeDate(thisYear))")
        println("thisWeek \(Formatters.formatRelativeDate(thisWeek))")
        println("yesterday \(Formatters.formatRelativeDate(yesterday))")
        println("today \(Formatters.formatRelativeDate(today))")
        println("minuteAgo \(Formatters.formatRelativeDate(minuteAgo))")
        println("secondsAgo \(Formatters.formatRelativeDate(secondsAgo))")
        println("justNow \(Formatters.formatRelativeDate(justNow))")
        
        expect(Formatters.formatRelativeDate(justNow)) == "just now"
    }
}