//
//  ConnectServicesViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/27/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

public struct ConnectServicesViewModel {
    
    let meteor: MeteorService
    
    public init(meteor: MeteorService) {
        self.meteor = meteor
    }

    public func finish() -> Future<Void, ErrorAlert> {
        let promise = Promise<(), ErrorAlert>()
        let count = Integration
            .by(IntegrationKeys.status_, value: Integration.Status.Linked.rawValue)
            .count()
        if count < 1 {
            promise.failure(ErrorAlert(title: "No Service Connected",
                message: "Please connect at least one service to coninue"))
        } else {
            promise.success()
        }
        return promise.future
    }
}