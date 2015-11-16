//
//  RootViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/21/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import CoreData
import ReactiveCocoa

public struct MainTabViewModel {
    let ctx: Context
    let prefetchedSubscriptions: [MeteorSubscription]
    
    public let chatsBadge: PropertyOf<String?>
    
    public init(_ ctx: Context) {
        self.ctx = ctx
        prefetchedSubscriptions = [
            ctx.meteor.subscribe("me"),
            ctx.meteor.subscribe("candidate-discover"),
            ctx.meteor.subscribe("my-hashtags")
        ]
        chatsBadge = ctx.layer.unreadCount.map { $0 > 0 ? "\($0)" : nil }
    }
}