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
    let termsAndConditionURL = NSURL("http://taylrapp.com/terms")
    let privacyURL = NSURL("http://taylrapp.com/privacy")
    let upgradeURL: NSURL
    let serverProtocol = "wss"
    let serverHostName: String
    var serverURL: NSURL {
        return NSURL("\(serverProtocol)://\(serverHostName)/websocket")
    }
    let oauthCallbackPath = "_oauth"
    let instagramClientId = "39f17d7de9e440cba144c960913bc1a4"
    let crashlyticsAPIKey = "4cdb005d0ddfebc8865c0a768de9b43c993e9113"
    let bugfenderAppToken: String
    let segmentWriteKey: String
    let heapAppId: String
    
    init(audience: Audience, provisioningProfile: ProvisioningProfile?) {
        self.audience = audience
        switch audience {
            case .Dev:
                upgradeURL = NSURL("https://apps-ios.crashlytics.com/projects/54f16f389f24291fde000043")
                serverHostName = "s10-dev.herokuapp.com"
//                serverHostName = "10.1.1.12:3000"
//                serverHostName = "s10-beta.herokuapp.com"
                bugfenderAppToken = "RBsiKkpkyiXUW2Sk50JTKTKUYlNpXsFn"
                segmentWriteKey = "vfnxR5SsgYkNQqRznBWHXDp2LMFkUNTv"
                heapAppId = "2150081452"
            case .Beta:
                upgradeURL = NSURL("https://taylrapp.com/beta")
                serverHostName = "s10-beta.herokuapp.com"
                bugfenderAppToken = "lO35cfZMdPxzIraCq4YFKISSKZ2EAIwe"
                segmentWriteKey = "SGEB9gVQGFYgeptFbtnETHCka8FCOuoc"
                heapAppId = "1572509943"
            case .AppStore:
                upgradeURL = NSURL("https://taylrapp.com/download")
                serverHostName = "s10.herokuapp.com"
                bugfenderAppToken = "ow9JOdNYSo5iVqPUUAEbS8HfmwZqb1tQ"
                segmentWriteKey = "JPCrmGwQqlgohXoowBFSLwesir9Zn5Bv"
                heapAppId = "538095372"
        }
        super.init(provisioningProfile: provisioningProfile)
    }
    
    class func configureFromEmbeddedProvisioningProfile() -> TaylrEnvironment {
        func audienceFromProfile(profile: ProvisioningProfile?) -> Audience {
            if TARGET_IPHONE_SIMULATOR == 1 {
                return .Dev
            }
            let profileType = profile?.type ?? .AppStore

            switch profileType {
                case .Development:      return .Dev
                case .Enterprise:       return .Beta
                case .Adhoc, .AppStore: return .AppStore
            }
        }
        let profile = ProvisioningProfile.embeddedProfile()
        return TaylrEnvironment(audience: audienceFromProfile(profile), provisioningProfile: profile)
    }
}