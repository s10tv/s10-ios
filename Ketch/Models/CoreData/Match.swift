//
//  Match.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/7/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

@objc(Match)
class Match: _Match {
    
    enum Choice : String {
        case Yes = "yes" // Marry
        case Maybe = "maybe" // Keep
        case No = "no" // Skip
    }

    class func findByDocumentID(documentID: String) -> Match? {
        return Core.mainContext.objectInCollection("matches", documentID: documentID) as? Match
    }

}
