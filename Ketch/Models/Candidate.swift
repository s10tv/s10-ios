//
//  Match.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/7/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

@objc(Candidate)
class Candidate: _Candidate {
    
    enum Choice : String {
        case Yes = "yes" // Marry
        case Maybe = "maybe" // Keep
        case No = "no" // Skip
    }

    class func candidateQueue() -> [Candidate] {
        return Candidate.all().fetch().map { $0 as Candidate }
    }

    class func findByDocumentID(documentID: String) -> Candidate? {
        return Core.mainContext.objectInCollection("matches", documentID: documentID) as? Candidate
    }

}
