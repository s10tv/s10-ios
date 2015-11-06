//
//  Environment.swift
//  Taylr
//
//  Created by Tony Xiao on 4/3/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import Core

class TaylrEnvironment : Environment {
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
    let serverProtocol = "ws"
    let serverHostName: String
    var serverURL: NSURL {
        return NSURL("\(serverProtocol)://\(serverHostName)/websocket")
    }
    let ouralabsKey = "5994e77086c6fcabc4bd5d5fe6c3e556"
    let uxcamKey = "2c0f24d77c8cdc6"
    let segmentWriteKey: String
    let mixpanelToken: String
    let amplitudeKey: String
    let layerURL: NSURL
    
    init(audience: Audience, provisioningProfile: ProvisioningProfile?) {
        self.audience = audience
        switch audience {
            case .Dev:
//                serverHostName = "localhost:3000"
//                serverHostName = "10.1.1.12:3000"
                serverHostName = "localhost:3000"
                segmentWriteKey = "pZimciABfGDaOLvEx9NWAFSoYHyCOg1n"
                amplitudeKey = "0ef2064f5f59aca8b1224ec4374064d3"
                mixpanelToken = "9d5d89ba988e52622278165d91ccf937"
                layerURL = NSURL("layer:///apps/staging/49574578-72bb-11e5-9a72-a4a211002a87")
            case .Beta, .AppStore:
                serverHostName = "taylr-prod.herokuapp.com"
                segmentWriteKey = "DwMJMhxsvn6EDrO33gANHBjvg3FUsfPJ"
                amplitudeKey = "ff96d68f3ff2efd39284b33a78dbbf2c"
                mixpanelToken = "39194eed490fa8abcc026256631a4230"
                layerURL = NSURL("layer:///apps/production/49574ba4-72bb-11e5-89fc-a4a211002a87")
        }
        super.init(provisioningProfile: provisioningProfile)
    }
    
    class func getAudience() -> Audience {
        if let id = NSBundle.mainBundle().bundleIdentifier where id == "tv.s10.taylr" {
            return Environment.isRunningTestFlightBeta() ? .Beta : .AppStore
        }
        return .Dev
    }
    
    class func configureFromEmbeddedProvisioningProfile() -> TaylrEnvironment {
        let profile = ProvisioningProfile.embeddedProfile()
        return TaylrEnvironment(audience: getAudience(), provisioningProfile: profile)
    }
}