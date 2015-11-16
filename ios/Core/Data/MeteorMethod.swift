//
//  MeteorMethod.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/7/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Meteor
import ReactiveCocoa

public class MeteorMethod {
    public let stubValue: AnyObject?
    public let future: Future<AnyObject?, NSError>
    
    public init(stubValue: AnyObject?, future: Future<AnyObject?, NSError>) {
        self.stubValue = stubValue
        self.future = future
    }
}
