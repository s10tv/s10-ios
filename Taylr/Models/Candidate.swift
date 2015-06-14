//
//  Match.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/7/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

@objc(Candidate)
class Candidate: _Candidate {

    class func findByDocumentID(documentID: String) -> Candidate? {
        return Meteor.mainContext.objectInCollection("candidates", documentID: documentID) as? Candidate
    }

}
