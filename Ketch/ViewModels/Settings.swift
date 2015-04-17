//
//  Settings.swift
//  Ketch
//
//  Created by Tony Xiao on 4/17/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import ReactiveCocoa

struct SettingsItem {
    enum ItemType : String {
        case Name = "name"
        case ProfilePhoto = "profilePhoto"
        case GenderPreference = "genderPreference"
        case Age = "age"
        case Work = "work"
        case Education = "education"
        case Height = "height"
        case About = "about"
    }
    let type: ItemType
    let value: Property
    let iconName: String?
    let formatBlock: (AnyObject? -> String)?
    
    var icon: UIImage? { return iconName.map { UIImage(named: $0) }? }
    var formattedText: String { return formatBlock?(value.current) ?? value.current?.description ?? "" }
    
    init(type: ItemType, iconName: String? = nil, formatBlock: (AnyObject? -> String)? = nil, updateBlock: (AnyObject? ->())? = nil) {
        self.type = type
        self.iconName = iconName
        self.formatBlock = formatBlock
        self.updateBlock = updateBlock
        self.value = Property()
    }
    
    internal let updateBlock: (AnyObject? ->())?
    internal func valueEquals(other: AnyObject?) -> Bool {
        switch (value.current, other) {
        case let (.Some(this), .Some(that)):
            switch (this, that) {
            case let (a as String, b as String):
                return a == b
            case let (a as Int, b as Int):
                return a == b
            default:
                return false
            }
        case (.None, .None):
            return true
        default:
            return false
        }
    }
}

func ==(a: SettingsItem.ItemType, b: SettingsItem.ItemType) -> Bool {
    return a.rawValue == b.rawValue
}

class SettingsViewModel {
    let currentUser: User
    let meta: Metadata
    let items: [SettingsItem] = []
    
    init(currentUser: User, meta: Metadata) {
        self.currentUser = currentUser
        self.meta = meta
        items = [
            ageItem(),
            heightItem()
        ]
    }
    
    func updateItem(type: SettingsItem.ItemType, newValue: AnyObject?) {
        let item = items.match { $0.type == type }!
        if item.valueEquals(newValue) != true {
            item.updateBlock?(newValue)
        }
    }

    private func ageItem() -> SettingsItem {
        return SettingsItem(
            type: .Age,
            iconName: R.KetchAssets.settingsAge.rawValue,
            formatBlock: { age in
                return ""
            }
        )
    }
    
    private func heightItem() -> SettingsItem {
        return SettingsItem(
            type: .Age,
            iconName: R.KetchAssets.settingsHeightArrow.rawValue,
            formatBlock: { height in
                return ""
            }, updateBlock: { newHeight in
//                Meteor.updateHeight()
            }
        )
    }
    
}








