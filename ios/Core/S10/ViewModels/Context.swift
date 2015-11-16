//
//  Context.swift
//  S10
//
//  Created by Tony Xiao on 10/15/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation

public struct Context {
    public let meteor: MeteorService
    public let layer: LayerService
    
    public var currentUserId: String? {
        return meteor.currentUser.userId.value
    }
    
    public init(meteor: MeteorService, layer: LayerService) {
        self.meteor = meteor
        self.layer = layer
    }
}