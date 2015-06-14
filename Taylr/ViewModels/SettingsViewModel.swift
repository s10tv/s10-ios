//
//  Settings.swift
//  Taylr
//
//  Created by Tony Xiao on 4/17/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Meteor

class SettingsViewModel {
    let currentUser: User
    let settings: Settings
    var items: [SettingsItem] = [] // TODO: Really should be let, not var, but yea.
    private var disposables: [RACDisposable] = []
    
    init(currentUser: User, settings: Settings) {
        self.currentUser = currentUser
        self.settings = settings
        self.items = createItems()
    }
    
    deinit {
        disposables.each { $0.dispose() }
    }
    
    func getItem(type: SettingsItem.ItemType) -> SettingsItem {
        return items.match { $0.type == type }!
    }
    
    // MARK: - Controlled Write Access
    
    func updateItem(type: SettingsItem.ItemType, newValue: AnyObject?) {
    }
    
    // MARK: - Helpers

    private func parseNullableString(input: AnyObject?) -> String {
        if let input = input as? String {
            return input
        }
        return ""
    }

    private func createItems() -> [SettingsItem] {
        return []
//        return [
//            // TODO: Use CoreData computed property to avoid hardcode string?
//            userItem(.Name, attr: "displayName"),
//            userItem(.ProfilePhoto, attr: "profilePhotoURL"),
//            userItem(.Age, icon: .settingsAge, attr: .age, editable: false) {
//                return ($0 as? Int).map { LS(.settingsAgeFormat, $0) } ?? LS(.settingsAgePrompt)
//            },
//            item(.GenderPreference, metadataKey: "genderPref", icon: .icBinocular, editable: true) {
//                return ($0 as? String).map { LS(.settingsGenderPreferenceFormat, Formatters.formatGenderPref($0)) } ?? LS(.settingsGenderPreferencePrompt)
//            },
//            userItem(.Work, icon: .settingsBriefcase, attr: .work) {
//                return ($0 as? String).map { LS(.settingsWorkFormat, $0) } ?? LS(.settingsWorkPrompt)
//            },
//            userItem(.Education, icon: .settingsMortarBoard, attr: .education) {
//                return ($0 as? String).map { LS(.settingsEducationFormat, $0) } ?? LS(.settingsEducationPrompt)
//            },
//            userItem(.Height, icon: .settingsHeightArrow, attr: .height) {
//                return ($0 as? Int).map { LS(.settingsHeightFormat, Formatters.formatHeight($0)) } ?? LS(.settingsHeightPrompt)
//            },
//            userItem(.About, icon: .settingsNotepad, attr: .about) {
//                return ($0 as? String) ?? LS(.settingsAboutPrompt)
//            }
//        ]
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
                let pairs = Array(changes.affectedDocumentKeys())
                    .map { $0 as! METDocumentKey }
                    .map { ($0.collectionName, $0.documentID as! String) }
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