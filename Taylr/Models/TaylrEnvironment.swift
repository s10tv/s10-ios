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
    let oauthCallbackPath = "_oauth"
    let instagramClientId = "39f17d7de9e440cba144c960913bc1a4"
    let crashlyticsAPIKey = "4cdb005d0ddfebc8865c0a768de9b43c993e9113"
    let segmentWriteKey: String
    let appseeApiKey: String
    let heapAppId: String
    let amplitudeKey: String
    let ouralabsKey = "5994e77086c6fcabc4bd5d5fe6c3e556"
    
    init(audience: Audience, provisioningProfile: ProvisioningProfile?) {
        self.audience = audience
        switch audience {
            case .Dev:
//                serverHostName = "localhost:3000"
//                serverHostName = "10.1.1.12:3000"
                serverHostName = "s10-dev.herokuapp.com"
                segmentWriteKey = "pZimciABfGDaOLvEx9NWAFSoYHyCOg1n"
                heapAppId = "2150081452"
                appseeApiKey = "90e5824e7a294045a992e56bbbb3f2f3"
                amplitudeKey = "3b3701a21192c042353851256b275185"
            case .Beta:
                serverHostName = "s10-beta.herokuapp.com"
                segmentWriteKey = "SGEB9gVQGFYgeptFbtnETHCka8FCOuoc" // this is wrong.
                heapAppId = "1572509943"
                appseeApiKey = "9a350ef30cb24154a547e8ebaebfe272"
                amplitudeKey = "3b3701a21192c042353851256b275185" // This is also wrong. Beta audience isn't really being used at the moment...
            case .AppStore:
                serverHostName = "taylr-prod.herokuapp.com"
                segmentWriteKey = "DwMJMhxsvn6EDrO33gANHBjvg3FUsfPJ"
                heapAppId = "538095372"
                appseeApiKey = "a33413513aab4ad296f379481caf8d90"
                amplitudeKey = "afe5fb04a3d90ca989e34a35092b6e33"
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