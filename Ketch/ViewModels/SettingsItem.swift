//
//  SettingsItem.swift
//  Ketch
//
//  Created by Tony Xiao on 4/17/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import ReactiveCocoa

struct SettingsItem {
    enum ItemType : String {
        case Name = "name"                          // String
        case ProfilePhoto = "profilePhoto"          // NSURL
        case GenderPreference = "genderPreference"  // String
        case Age = "age"                            // Int
        case Work = "work"                          // String
        case Education = "education"                // String
        case Height = "height"                      // Int (cm)
        case About = "about"                        // String
    }
    let type: ItemType
    let value: Property
    let iconName: String?
    let formatBlock: (AnyObject? -> String)?
    let editable: Bool
    
    var icon: UIImage? { return iconName.map { UIImage(named: $0) }? }
    var formattedText: String { return formatBlock?(value.current) ?? value.current?.description ?? "" }
    
    init(type: ItemType, iconName: String? = nil, editable: Bool = true, formatBlock: (AnyObject? -> String)? = nil, updateBlock: (AnyObject? ->())? = nil) {
        self.type = type
        self.iconName = iconName
        self.formatBlock = formatBlock
        self.editable = editable
        self.value = Property()
    }
}

func ==(a: SettingsItem.ItemType, b: SettingsItem.ItemType) -> Bool {
    return a.rawValue == b.rawValue
}
