//
//  IntegrationListViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/24/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Bond

public struct IntegrationListViewModel {
    let meteor: MeteorService
    public let integrations: DynamicArray<IntegrationViewModel>
    
    public init(meteor: MeteorService) {
        self.meteor = meteor
        integrations = Integration
            .sorted(by: IntegrationKeys.linkedAccountName.rawValue, ascending: true)
            .results(Integration)
            .map { IntegrationViewModel(integration: $0) }
    }
    
    public func subscribe() {
        meteor.subscribe("integrations")
    }
}