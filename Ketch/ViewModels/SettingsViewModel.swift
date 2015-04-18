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
    
    // MARK: - Controlled Write Access
    
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
            userItem(.Name, attr: "displayName"),
            userItem(.ProfilePhoto, attr: "profilePhotoURL"),
            userItem(.Age, icon: .settingsAge, attr: .age, editable: false) {
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
                return ($0 as? Int).map { "You're about \(Formatters.formatHeight($0)) tall" } ?? "What's your height?"
            },
            userItem(.About, icon: .settingsNotepad, attr: .about) {
                return ($0 as? String) ?? "Enter your bio"
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
