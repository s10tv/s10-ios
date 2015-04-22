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

class SettingsViewModel {
    let currentUser: User
    let settings: Settings
    let items: [SettingsItem] = []
    private var disposables: [RACDisposable] = []
    
    init(currentUser: User, settings: Settings) {
        self.currentUser = currentUser
        self.settings = settings
        items = createItems()
    }
    
    deinit {
        disposables.each { $0.dispose() }
    }
    
    func getItem(type: SettingsItem.ItemType) -> SettingsItem {
        return items.match { $0.type == type }!
    }
    
    // MARK: - Controlled Write Access
    
    func updateItem(type: SettingsItem.ItemType, newValue: AnyObject?) {
        switch (type) {
        case .GenderPreference:
            if let pref = Settings.GenderPref(rawValue: newValue as String) {
                if settings.genderPref != pref {
                    Meteor.updateGenderPref(pref)
                }
            }
        case .Work:
            let workInfo = parseNullableString(newValue)
            if currentUser.work != workInfo {
                Meteor.updateWork(workInfo)
            }
        case .Education:
            let educationInfo = parseNullableString(newValue)
            if currentUser.education != educationInfo {
                Meteor.updateEducation(educationInfo)
            }
        case .Height:
            let heightInfo = parseNullableInt(newValue)
            if currentUser.height != heightInfo {
                Meteor.updateHeight(heightInfo)
            }
        case .About:
            let aboutInfo = parseNullableString(newValue)
            if currentUser.about != aboutInfo {
                Meteor.updateAbout(aboutInfo)
            }
        default:
            break
        }
    }
    
    // MARK: - Helpers

    private func parseNullableString(input: AnyObject?) -> String {
        if let input = input as? String {
            return input
        }
        return ""
    }
    
    private func parseNullableInt(input: AnyObject?) -> Int {
        if let input = input as? Int {
            return input
        }
        return 0
    }

    private func createItems() -> [SettingsItem] {
        return [
            // TODO: Use CoreData computed property to avoid hardcode string?
            userItem(.Name, attr: "displayName"),
            userItem(.ProfilePhoto, attr: "profilePhotoURL"),
            userItem(.Age, icon: .settingsAge, attr: .age, editable: false) {
                return ($0 as? Int).map { LS(.settingsAgeFormat, $0) } ?? LS(.settingsAgePrompt)
            },
            item(.GenderPreference, metadataKey: "genderPref", icon: .icBinocular, editable: true) {
                return ($0 as? String).map { LS(.settingsGenderPreferenceFormat, Formatters.formatGenderPref($0)) } ?? LS(.settingsGenderPreferencePrompt)
            },
            userItem(.Work, icon: .settingsBriefcase, attr: .work) {
                return ($0 as? String).map { LS(.settingsWorkFormat, $0) } ?? LS(.settingsWorkPrompt)
            },
            userItem(.Education, icon: .settingsMortarBoard, attr: .education) {
                return ($0 as? String).map { LS(.settingsEducationFormat, $0) } ?? LS(.settingsEducationPrompt)
            },
            userItem(.Height, icon: .settingsHeightArrow, attr: .height) {
                return ($0 as? Int).map { LS(.settingsHeightFormat, Formatters.formatHeight($0)) } ?? LS(.settingsHeightPrompt)
            },
            userItem(.About, icon: .settingsNotepad, attr: .about) {
                return ($0 as? String) ?? LS(.settingsAboutPrompt)
            }
        ]
    }
    
    // MARK: More Helpers
    
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
    
    private func item(type: SettingsItem.ItemType, metadataKey: String, icon: R.KetchAssets? = nil, editable: Bool = true, format: (AnyObject? -> String)? = nil) -> SettingsItem {
        let item = SettingsItem(type: type, iconName: icon?.rawValue, editable: editable, formatBlock: format)
        item.value._update(settings.getValue(metadataKey))
        disposables += NC.rac_addObserverForName(METDatabaseDidChangeNotification, object: nil).deliverOnMainThread().subscribeNextAs {
            (notification: NSNotification) in
            if let changes = notification.userInfo?[METDatabaseChangesKey] as? METDatabaseChanges {
                // TODO: This has been duplicated way too many times, refactor
                let pairs = changes.affectedDocumentKeys().allObjects
                    .map { $0 as METDocumentKey }
                    .map { ($0.collectionName, $0.documentID as String) }
                for (name, key) in pairs {
                    if name == "settings" && key == metadataKey {
                        item.value._update(self.settings.getValue(key))
                    }
                }
            }
        }
        return item
    }
}
