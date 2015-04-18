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
        switch (type, newValue) {
        case let (.GenderPreference, genderPreference as String):
            if meta.getValue("genderPreference") as? String != genderPreference {
                Meteor.updateGenderPreference(genderPreference)
            }
        case let (.Work, work as String):
            if currentUser.work != work {
                Meteor.updateWork(work)
            }
        case let (.Education, education as String):
            if currentUser.education != education {
                Meteor.updateEducation(education)
            }
        case let (.Height, height as Int):
            if currentUser.height != height {
                Meteor.updateHeight(height)
            }
        case let (.About, about as String):
            if currentUser.about != about {
                Meteor.updateAbout(about)
            }
        default:
            break
        }
    }
    
    // MARK: - Helpers
    
    private func createItems() -> [SettingsItem] {
        return [
            // TODO: Use CoreData computed property to avoid hardcode string?
            userItem(.Name, attr: "displayName", editable: false),
            userItem(.ProfilePhoto, attr: "profilePhotoURL", editable: false),
            userItem(.Age, icon: .settingsAge, attr: .age) {
                return $0.map { "\($0) years old" } ?? "Set your age in Facebook"
            },
            metaItem(.GenderPreference, metadataKey: "genderPreference", icon: .icBinocular, editable: true) {
                return $0.map { "Interested in \($0)" } ?? "Set your gender preference"
            },
            userItem(.Work, icon: .settingsBriefcase, attr: .work) {
                return $0.map { "You are a \($0)" } ?? "Enter your job title"
            },
            userItem(.Education, icon: .settingsMortarBoard, attr: .education) {
                return $0.map { "Studied at \($0)" } ?? "Enter where you went to school"
            },
            userItem(.Height, icon: .settingsHeightArrow, attr: .height) {
                return $0.map { "You're about \($0)cm tall" } ?? "What's your height?"
            },
            userItem(.About, icon: .settingsNotepad, attr: .about) {
                return ($0 as? String) ?? "Enter your bio"
            }
        ]
    }
    
    private func userItem(type: SettingsItem.ItemType, icon: R.KetchAssets? = nil, attr: UserAttributes, editable: Bool = true, format: (AnyObject? -> String)? = nil) -> SettingsItem {
        return userItem(type, icon: icon, attr: attr.rawValue, editable: editable, format: format)
    }
    
    private func userItem(type: SettingsItem.ItemType, icon: R.KetchAssets? = nil, attr: String, editable: Bool = true, format: (AnyObject? -> String)? = nil) -> SettingsItem {
        let item = SettingsItem(type: type, iconName: icon?.rawValue, editable: editable, formatBlock: format)
        disposables += currentUser.racObserve(attr).subscribeNext {
            item.value._update($0)
        }
        return item
    }
    
    private func metaItem(type: SettingsItem.ItemType, metadataKey: String, icon: R.KetchAssets? = nil, editable: Bool = true, format: (AnyObject? -> String)? = nil) -> SettingsItem {
        let item = SettingsItem(type: type, iconName: icon?.rawValue, editable: editable, formatBlock: format)
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
