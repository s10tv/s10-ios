//
//  TaskManager.swift
//  Taylr
//
//  Created by Tony Xiao on 6/16/15.
//  Copyright (c) 2015 Taylr. All rights reserved.
//

import Foundation
import ReactiveCocoa

class Task {
    let clientId: String
    let type: String
    let signal: RACSignal = RACReplaySubject()
    
    init(clientId: String, type: String) {
        self.clientId = clientId
        self.type = type
    }
    
    func start() {
    }
    func cancel() {
    }
}