//
//  Environment.swift
//  Taylr
//
//  Created by Tony Xiao on 4/3/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import Core

let IS_TARGET_IPHONE_SIMULATOR = (TARGET_IPHONE_SIMULATOR == 1)

class TaylrEnvironment : Environment {
    enum Audience {
        case Dev, Beta, AppStore
        var urlScheme: String {
            switch self {
            case .Dev: return "taylr-dev://"
            case .Beta: return "taylr-beta://"
            case .AppStore: return "taylr://"
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
    let ouralabsKey = "5994e77086c6fcabc4bd5d5fe6c3e556"
    let uxcamKey = "2c0f24d77c8cdc6"
    let segmentWriteKey: String
    let mixpanelToken: String
    let amplitudeKey: String
    
    init(audience: Audience, provisioningProfile: ProvisioningProfile?) {
        self.audience = audience
        switch audience {
            case .Dev:
//                serverHostName = "localhost:3000"
//                serverHostName = "10.1.1.12:3000"
                serverHostName = "s10-dev.herokuapp.com"
                segmentWriteKey = "pZimciABfGDaOLvEx9NWAFSoYHyCOg1n"
                amplitudeKey = "3b3701a21192c042353851256b275185"
                mixpanelToken = "255ede53d2307ab3a8a51314822c5f50"
            case .Beta:
                serverHostName = "s10-beta.herokuapp.com"
                segmentWriteKey = "SGEB9gVQGFYgeptFbtnETHCka8FCOuoc" // this is wrong.
                amplitudeKey = "3b3701a21192c042353851256b275185" // This is also wrong. Beta audience isn't really being used at the moment...
                mixpanelToken = "39194eed490fa8abcc026256631a4230"
            case .AppStore:
                serverHostName = "taylr-prod.herokuapp.com"
                segmentWriteKey = "DwMJMhxsvn6EDrO33gANHBjvg3FUsfPJ"
                amplitudeKey = "afe5fb04a3d90ca989e34a35092b6e33"
                mixpanelToken = "a62700cc1f055205f3b18ff95fdefc62"
        }
        super.init(provisioningProfile: provisioningProfile)
    }
    
    class func configureFromEmbeddedProvisioningProfile() -> TaylrEnvironment {
        let profile = ProvisioningProfile.embeddedProfile()
        func getAudience() -> Audience {
            if IS_TARGET_IPHONE_SIMULATOR {
                switch NSBundle.mainBundle().bundleIdentifier ?? "" {
                    case "tv.s10.taylr": return .AppStore
                    case "tv.s10.taylr.beta": return .Beta
                    default: return .Dev
                }
            }
            let profileType = profile?.type ?? .AppStore

            switch profileType {
                case .Development:      return .Dev
                case .Enterprise:       return .Beta
                case .Adhoc, .AppStore: return .AppStore
            }
        }
        return TaylrEnvironment(audience: getAudience(), provisioningProfile: profile)
    }
}