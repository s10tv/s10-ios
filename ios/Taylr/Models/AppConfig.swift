//
//  AppConfig.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import UIKit

class AppConfig {
    enum Audience: String {
        case Dev = "dev", Beta = "beta", AppStore = "appstore"
        var urlScheme: String {
            switch self {
            case .Dev: return "taylr-dev://"
            case .Beta, .AppStore: return "taylr://"
            }
        }
        var installed: Bool {
            return UIApplication.sharedApplication().canOpenURL(NSURL(urlScheme))
        }
    }
    
    let audience : Audience
    let serverProtocol = "wss"
    let serverHostName: String
    var serverURL: NSURL {
        return NSURL("\(serverProtocol)://\(serverHostName)/websocket")
    }
    let uxcamKey = "2c0f24d77c8cdc6"
    let ouralabsKey: String
    let segmentWriteKey: String
    let mixpanelToken: String
    let amplitudeKey: String
    let layerURL: NSURL
    let appHubApplicationId = "uCG85kfu67WewOZVEQBk"
    let branchKey: String
    let intercom: (appId: String, apiKey: String) = (
        appId: "q6ihw9uw",
        apiKey: "ios_sdk-d849f0f2673a478473e25615616acf139b0e28a9"
    )
    
    init(audience: Audience) {
        self.audience = audience
        switch audience {
        case .Dev:
//                serverHostName = "localhost:3000"
//                serverHostName = "10.1.1.12:3000"
            serverHostName = "s10-dev.herokuapp.com"
            segmentWriteKey = "pZimciABfGDaOLvEx9NWAFSoYHyCOg1n"
            amplitudeKey = "0ef2064f5f59aca8b1224ec4374064d3"
            mixpanelToken = "9d5d89ba988e52622278165d91ccf937"
            branchKey = "key_test_nmeOiHF7jxXUcZPa8UdDbaacBxdYkU1J"
            ouralabsKey = "2207bb0177c84bd22085cb4e9018246f"
            layerURL = NSURL("layer:///apps/staging/49574578-72bb-11e5-9a72-a4a211002a87")
        case .Beta, .AppStore:
            serverHostName = "taylr-prod.herokuapp.com"
            segmentWriteKey = "DwMJMhxsvn6EDrO33gANHBjvg3FUsfPJ"
            amplitudeKey = "ff96d68f3ff2efd39284b33a78dbbf2c"
            mixpanelToken = "39194eed490fa8abcc026256631a4230"
            branchKey = "key_live_clkHkRr6mC5Ok8Np3LeBbldcqAj8eUY4"
            ouralabsKey = "96128c67ffeb9632f665febb71914dc5"
            layerURL = NSURL("layer:///apps/production/49574ba4-72bb-11e5-89fc-a4a211002a87")
        }
    }
    
    convenience init(env: Environment) {
        if env.appId == "tv.s10.taylr" {
            self.init(audience: env.isRunningTestFlightBeta ? .Beta : .AppStore)
        } else {
            self.init(audience: .Dev)
        }
    }
}