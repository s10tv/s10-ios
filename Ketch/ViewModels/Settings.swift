//
//  Settings.swift
//  Ketch
//
//  Created by Tony Xiao on 4/17/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Meteor

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
    private var disposables: [RACDisposable] = []
    
    init(currentUser: User, meta: Metadata) {
        self.currentUser = currentUser
        self.meta = meta
        items = createItems()
    }
    
    deinit {
        disposables.each { $0.dispose() }
    }
    
    func getItem(type: SettingsItem.ItemType) -> SettingsItem {
        return items.match { $0.type == type }!
    }
    
    func updateItem(type: SettingsItem.ItemType, newValue: AnyObject?) {
        let item = getItem(type)
        if item.valueEquals(newValue) != true {
            item.updateBlock?(newValue)
            println("Value \(type.rawValue) has changed to \(newValue)")
        }
    }
    
    // MARK: - Helpers
    
    private func createItems() -> [SettingsItem] {
        return [
            // TODO: Use CoreData computed property to avoid hardcode string?
            userItem(.Name, attr: "displayName"),
            userItem(.ProfilePhoto, attr: "profilePhotoURL"),
            userItem(.Age, icon: .settingsAge, attr: .age, format: {
                return $0.map { "\($0) years old" } ?? "Set your age in Facebook"
            }),
            metaItem(.GenderPreference, icon: .icBinocular, metadataKey: "genderPreference", format: {
                return $0.map { "Interested in \($0)" } ?? "Set your gender preference"
            }, update: {
                ($0 as? String).map { Meteor.updateGenderPreference($0) }; return
            }),
            userItem(.Work, icon: .settingsBriefcase, attr: .work, format: {
                return $0.map { "You are a \($0)" } ?? "Enter your job title"
            }, update: {
                ($0 as? String).map { Meteor.updateWork($0) }; return
            }),
            userItem(.Education, icon: .settingsMortarBoard, attr: .education, format: {
                return $0.map { "Studied at \($0)" } ?? "Enter where you went to school"
            }, update: {
                ($0 as? String).map { Meteor.updateEducation($0) }; return
            }),
            userItem(.Height, icon: .settingsHeightArrow, attr: .height, format: {
                return $0.map { "You're about \($0)cm tall" } ?? "What's your height?"
            }, update: {
                ($0 as? Int).map { Meteor.updateHeight($0) }; return
            }),
            userItem(.About, icon: .settingsNotepad, attr: .about, format: {
                return ($0 as? String) ?? "Enter your bio"
            }, update: {
                ($0 as? String).map { Meteor.updateAbout($0) }; return
            })
        ]
    }
    
    private func userItem(type: SettingsItem.ItemType, icon: R.KetchAssets? = nil, attr: UserAttributes, format: (AnyObject? -> String)? = nil, update: (AnyObject? ->())? = nil) -> SettingsItem {
        return userItem(type, icon: icon, attr: attr.rawValue, format: format, update: update)
    }
    
    private func userItem(type: SettingsItem.ItemType, icon: R.KetchAssets? = nil, attr: String, format: (AnyObject? -> String)? = nil, update: (AnyObject? ->())? = nil) -> SettingsItem {
        let item = SettingsItem(type: type, iconName: icon?.rawValue, formatBlock: format, updateBlock: update)
        disposables += currentUser.racObserve(attr).subscribeNext {
            item.value._update($0)
        }
        return item
    }
    
    private func metaItem(type: SettingsItem.ItemType, icon: R.KetchAssets? = nil, metadataKey: String, format: (AnyObject? -> String)? = nil, update: (AnyObject? ->())? = nil) -> SettingsItem {
        let item = SettingsItem(type: type, iconName: icon?.rawValue, formatBlock: format, updateBlock: update)
        disposables += NC.rac_addObserverForName(METDatabaseDidChangeNotification, object: nil).subscribeNextAs {
            (notification: NSNotification) in
            if let changes = notification.userInfo?[METDatabaseChangesKey] as? METDatabaseChanges {
                // TODO: This has been duplicated way too many times, refactor
                let pairs = changes.affectedDocumentKeys().allObjects
                    .map { $0 as METDocumentKey }
                    .map { ($0.collectionName, $0.documentID as String) }
                for (name, key) in pairs {
                    if name == "metadata" && key == metadataKey {
                        item.value._update(self.meta.getValue(key))
                    }
                }
            }
        }
        return item
    }
}
