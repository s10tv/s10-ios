//
//  Settings.swift
//  Taylr
//
//  Created by Tony Xiao on 4/19/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import Meteor

public class Settings {
    public enum Key : String {
        case SoftMinBuild = "softMinBuild"
        case HardMinBuild = "hardMinBuild"
        case EdgePanEnabled = "edgePanEnabled"
        case CrabUserId = "crabUserId"
        case Vetted = "vetted"
        case Email = "email"
        case GenderPref = "genderPref"
        case DebugLoginMode = "debugLoginMode"
    }
    public enum GenderPref : String {
        case Men = "men"
        case Women = "women"
        case Both = "both"
    }
    public let collection : METCollection
    
    public var softMinBuild : Int? { return getValue(.SoftMinBuild) as? Int }
    public var hardMinBuild : Int? { return getValue(.HardMinBuild) as? Int }
    public var edgePanEnabled: Bool? { return getValue(.EdgePanEnabled) as? Bool }
    public var crabUserId : String? { return getValue(.CrabUserId) as? String }
    public var vetted : Bool? { return getValue(.Vetted) as? Bool }
    public var email : String? { return getValue(.Email) as? String }
    public var genderPref : GenderPref? {
        return GenderPref(rawValue: (getValue(.GenderPref) as? String) ?? "")
    }
    public var debugLoginMode: Bool { return getValue(.DebugLoginMode) as? Bool ?? false }
    
    public init(collection: METCollection) {
        self.collection = collection
    }
    
    public func getValue(key: String) -> AnyObject? {
        return collection.documentWithID(key).fields["value"]
    }
    
    public func getValue(key: Key) -> AnyObject? {
        return getValue(key.rawValue)
    }
}
