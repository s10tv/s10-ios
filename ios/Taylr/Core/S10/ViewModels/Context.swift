//
//  Context.swift
//  S10
//
//  Created by Tony Xiao on 10/15/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation

public struct Context {
    public let layer: LayerService
    
    public var currentUserId: String? {
        return nil
    }
    
    public init(layer: LayerService) {
        self.layer = layer
    }
}