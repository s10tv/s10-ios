//
//  FutureExtensions.swift
//  S10
//
//  Created by Tony Xiao on 7/9/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import BrightFutures

func perform<T, E>(@noescape futureProducer: () -> Future<T, E>) -> Future<T, E> {
    return futureProducer()
}

