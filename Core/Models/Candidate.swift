//
//  Match.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/7/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

@objc(Candidate)
public class Candidate: _Candidate {

    public class func findByDocumentID(context: NSManagedObjectContext, documentID: String) -> Candidate? {
        return context.objectInCollection("candidates", documentID: documentID) as? Candidate
    }

}
