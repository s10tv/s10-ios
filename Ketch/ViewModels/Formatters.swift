//
//  Formatters.swift
//  Ketch
//
//  Created by Tony Xiao on 4/17/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

struct Formatters {
    static let heightFormatter : NSLengthFormatter = {
        let formatter = NSLengthFormatter()
        formatter.forPersonHeightUse = true
        formatter.unitStyle = .Short
        formatter.numberFormatter.maximumFractionDigits = 0
        return formatter
    }()
    
    static func formatHeight(heightInCm: Int) -> String {
        return heightFormatter.stringFromMeters(Double(heightInCm) / 100)
    }
}