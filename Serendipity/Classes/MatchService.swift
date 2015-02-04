//
//  MatchService.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/4/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation

let MatchService = MatchServiceImpl()

class MatchServiceImpl {
    
    private var queue : [User] = []
    private(set) var currentMatch : User? = nil
    
    func getNextMatch() -> RACSignal {
        let subject = RACReplaySubject()
        
        return subject
    }
}

