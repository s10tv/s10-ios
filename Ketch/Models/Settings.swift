//
//  Settings.swift
//  Ketch
//
//  Created by Tony Xiao on 4/19/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import Meteor

class Settings {
    private let collection : METCollection
    
    var softMinBuild : Int? { return getValue("softMinBuild") as? Int }
    var hardMinBuild : Int? { return getValue("hardMinBuild") as? Int }
    var crabUserId : String? { return getValue("crabUserId") as? String }
    var vetted : Bool? { return getValue("vetted") as? Bool }
    var email : String? { return getValue("email") as? String }
    var genderPref : GenderPref? {
        return (getValue("genderPref") as? String).map { GenderPref(rawValue: $0) }?
    }
    
    init(collection: METCollection) {
        self.collection = collection
    }
    
    func getValue(key: String) -> AnyObject? {
        return collection.documentWithID(key)?.fields["value"]
    }
}