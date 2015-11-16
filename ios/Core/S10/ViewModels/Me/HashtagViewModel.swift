//
//  Hashtag.swift
//  S10
//
//  Created by Tony Xiao on 10/10/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation

public struct HashtagViewModel {
    public let text: String
    
    public var selected: Bool
    public var displayText: String {
        return "#\(text)"
    }
    
    init(hashtag: Hashtag) {
        self.text = hashtag.text
        self.selected = hashtag.selected?.boolValue ?? false
    }
    
    public init(text: String, selected: Bool) {
        self.text = text
        self.selected = selected
    }
}
