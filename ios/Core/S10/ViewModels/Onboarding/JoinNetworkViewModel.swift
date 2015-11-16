//
//  JoinNetworkViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/27/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

public struct JoinNetworkViewModel {
    let ctx: Context

    public init(_ ctx: Context) {
        self.ctx = ctx
    }

    public func joinNetwork(networkId: String, token: String) -> SignalProducer<(), ErrorAlert> {
        return ctx.meteor.joinNetwork("ubc", token: token).producer
            .mapError {
                ErrorAlert(title: "Registration Problem",
                    message: $0.localizedFailureReason ?? "Please try again later.")
            }
            .observeOn(UIScheduler())
    }
}