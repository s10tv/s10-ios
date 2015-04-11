//
//  MetadataService.swift
//  Ketch
//
//  Created by Tony Xiao on 4/9/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import Meteor

class MetadataService {
    private let collection : METCollection
    
    var softMinBuild : Int? { return valueForMetadataKey("softMinBuild") as? Int }
    var hardMinBuild : Int? { return valueForMetadataKey("hardMinBuild") as? Int }
    var crabUserId : String? { return valueForMetadataKey("crabUserId") as? String }
    var vetted : Bool? { return valueForMetadataKey("vetted") as? Bool }
    
    // MARK: -
    
    init(collection: METCollection) {
        self.collection = collection
    }
    
    private func valueForMetadataKey(key: String) -> AnyObject? {
        return collection.documentWithID(key)?.fields["value"]
    }
}