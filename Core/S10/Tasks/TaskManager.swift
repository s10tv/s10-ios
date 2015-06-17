//
//  TaskManager.swift
//  Taylr
//
//  Created by Tony Xiao on 6/16/15.
//  Copyright (c) 2015 Taylr. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Meteor

public class Task {
    let clientId: String
    let type: String
    let signal: RACSignal = RACReplaySubject()
    
    public init(clientId: String, type: String) {
        self.clientId = clientId
        self.type = type
    }
    
    func start() {
    }
    func cancel() {
    }
}