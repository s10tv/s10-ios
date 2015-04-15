//
//  MetadataService.swift
//  Ketch
//
//  Created by Tony Xiao on 4/9/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import Meteor

class Metadata {
    private let collection : METCollection
    
    // MARK: Read-only properties
    
    var softMinBuild : Int? { return getValue("softMinBuild") as? Int }
    var hardMinBuild : Int? { return getValue("hardMinBuild") as? Int }
    var crabUserId : String? { return getValue("crabUserId") as? String }
    var vetted : Bool? { return getValue("vetted") as? Bool }
    var email : String? { return getValue("email") as? String }
    
    // MARK: Read-write properties
    
    var bugfenderId: String? {
        get { return getValue("bugfenderId") as? String }
        set { setValue(newValue, metadataKey: "bugfenderId") }
    }
    var gameTutorialMode: Bool? {
        get { return getValue("gameTutorialMode") as? Bool }
        set { setValue(newValue, metadataKey: "gameTutorialMode") }
    }
    var hasBeenWelcomed: Bool? {
        get { return getValue("hasBeenWelcomed") as? Bool }
        set { setValue(newValue, metadataKey: "hasBeenWelcomed") }
    }
    var debugState: FlowService.State? {
        get { return (getValue("debugState") as? String).map { FlowService.State(rawValue: $0) }? }
        set { setValue(newValue?.rawValue, metadataKey: "debugState") }
    }
    
    // MARK: -
    
    init(collection: METCollection) {
        self.collection = collection
    }
    
    func getValue(metadataKey: String) -> AnyObject? {
        return collection.documentWithID(metadataKey)?.fields["value"]
    }
    
    func setValue(value: AnyObject?, metadataKey: String) {
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