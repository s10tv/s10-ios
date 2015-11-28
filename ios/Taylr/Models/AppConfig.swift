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
    let appHubApplicationId = "uCG85kfu67WewOZVEQBk"
    let layerURL: NSURL
    let oneSignalAppId: String
    let ouralabsKey: String
    let branchKey: String
    let segmentWriteKey: String
    let amplitude: (appId: String, apiKey: String)
    let mixpanel: (projectId: String, token: String)
    let intercom: (appId: String, apiKey: String)
    
    init(audience: Audience) {
        self.audience = audience
        switch audience {
        case .Dev:
//            serverHostName = "localhost:3000"
            serverHostName = "s10-dev.herokuapp.com"
            layerURL = NSURL("layer:///apps/staging/49574578-72bb-11e5-9a72-a4a211002a87")
            oneSignalAppId = "1fe37e84-77a0-11e5-ace7-2baf094fe5d2"
            ouralabsKey = "2207bb0177c84bd22085cb4e9018246f"
            branchKey = "key_test_nmeOiHF7jxXUcZPa8UdDbaacBxdYkU1J"
            segmentWriteKey = "pZimciABfGDaOLvEx9NWAFSoYHyCOg1n"
            amplitude = (appId: "137713", apiKey: "0ef2064f5f59aca8b1224ec4374064d3")
            mixpanel = (projectId: "773277", token: "9d5d89ba988e52622278165d91ccf937")
            intercom = (
                appId: "qh519efm",
                apiKey: "ios_sdk-25fc29ac38aa81d8f4aff0d387b84dabf06bd397"
            )
        case .Beta, .AppStore:
            serverHostName = "taylr-prod.herokuapp.com"
            layerURL = NSURL("layer:///apps/production/49574ba4-72bb-11e5-89fc-a4a211002a87")
            oneSignalAppId = "82ee7482-77a2-11e5-8563-5bcba87018a1"
            ouralabsKey = "96128c67ffeb9632f665febb71914dc5"
            branchKey = "key_live_clkHkRr6mC5Ok8Np3LeBbldcqAj8eUY4"
            segmentWriteKey = "DwMJMhxsvn6EDrO33gANHBjvg3FUsfPJ"
            amplitude = (appId: "137712", apiKey: "ff96d68f3ff2efd39284b33a78dbbf2c")
            mixpanel = (projectId: "671741", token: "39194eed490fa8abcc026256631a4230")
            intercom = (
                appId: "q6ihw9uw",
                apiKey: "ios_sdk-2f6aefd7197daa0cf771aacf5545a0a8aba70955"
            )
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