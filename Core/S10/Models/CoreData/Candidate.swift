//
//  Candidate.swift
//  S10
//
//  Created on 1/20/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

@objc(Candidate)
internal class Candidate: _Candidate {

    enum Status : String {
        case Active = "active"
        case Pending = "pending"
        case Expired = "expired"
    }
    
    var status: Status {
        return Status(rawValue: status_)!
    }
}
