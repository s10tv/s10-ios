//
//  Globals.swift
//  Taylr
//
//  Created by Tony Xiao on 4/18/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import Core
import React

struct GlobalsContainer {
    let env: TaylrEnvironment
    let meteorService: MeteorService
    let accountService: AccountService
    let analyticsService : AnalyticsService
    let upgradeService: UpgradeService
    let layerService: LayerService
    let reactBridge: RCTBridge
}

