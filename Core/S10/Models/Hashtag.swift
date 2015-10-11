//
//  Hashtag.swift
//  S10
//
//  Created by Tony Xiao on 10/10/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation

public struct Hashtag {
    public let text: String
    
    public var selected: Bool
    public var displayText: String {
        return "#\(text)"
    }
}