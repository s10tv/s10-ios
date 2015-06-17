//
//  MetadataService.swift
//  Taylr
//
//  Created by Tony Xiao on 4/9/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import Meteor

public class Metadata {
    public enum Key : String {
        case BugfenderId = "bugfenderId"
        case GameTutorialMode = "gameTutorialMode"
        case DemoMode = "demoMode"
        case HasBeenWelcomed = "hasBeenWelcomed"
        case LogVerboseState = "logVerboseState"
    }
    public let collection : METCollection
    
    public var bugfenderId: String? {
        get { return getValue(.BugfenderId) as? String }
        set { setValue(newValue, key: .BugfenderId) }
    }
    public var gameTutorialMode: Bool? {
        get { return getValue(.GameTutorialMode) as? Bool }
        set { setValue(newValue, key: .GameTutorialMode) }
    }
    public var demoMode: Bool? {
        get { return getValue(.DemoMode) as? Bool }
        set { setValue(newValue, key: .DemoMode) }
    }
    public var hasBeenWelcomed: Bool? {
        get { return getValue(.HasBeenWelcomed) as? Bool }
        set { setValue(newValue, key: .HasBeenWelcomed) }
    }
    public var logVerboseState: Bool {
        get { return getValue(.LogVerboseState) as? Bool ?? false }
        set { setValue(newValue, key: .LogVerboseState) }
    }
    
    // MARK: -
    
    public init(collection: METCollection) {
        self.collection = collection
    }
    
    // Safe
    public func getValue(key: Key) -> AnyObject? {
        return getValue(key.rawValue)
    }
    
    public func setValue(value: AnyObject?, key: Key) {
        setValue(value, metadataKey: key.rawValue)
    }
    
    // Unsafe
    public func getValue(metadataKey: String) -> AnyObject? {
        return collection.documentWithID(metadataKey).fields["value"]
    }
    
    public func setValue(value: AnyObject?, metadataKey: String) {
        if let value: AnyObject = value {
            if getValue(metadataKey) == nil {
                collection.insertDocumentWithID(metadataKey, fields: ["value": value])
            } else {
                collection.updateDocumentWithID(metadataKey, changedFields: ["value": value])
            }
        } else {
            collection.removeDocumentWithID(metadataKey)
        }
    }
    
}