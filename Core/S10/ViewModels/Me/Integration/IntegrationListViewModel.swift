//
//  IntegrationListViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/24/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation

public struct IntegrationListViewModel {
    let subscription: MeteorSubscription
    public let integrations: FetchedResultsArray<IntegrationViewModel>
    
    public init(_ ctx: Context) {
        subscription = ctx.meteor.subscribe("integrations")
        integrations = Integration
            .sorted(by: IntegrationKeys.status_.rawValue, ascending: true)
            .sorted(by: IntegrationKeys.updatedAt.rawValue, ascending: true)
            .results { IntegrationViewModel(integration: $0 as! Integration) }
    }
}
