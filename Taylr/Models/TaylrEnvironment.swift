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
    let upgradeURL: NSURL
    let serverProtocol = "wss"
    let serverHostName: String
    var serverURL: NSURL {
        return NSURL("\(serverProtocol)://\(serverHostName)/websocket")
    }
    let oauthCallbackPath = "_oauth"
    let instagramClientId = "39f17d7de9e440cba144c960913bc1a4"
    let crashlyticsAPIKey = "4cdb005d0ddfebc8865c0a768de9b43c993e9113"
    let githubClientId: String
    let githubClientSecret: String
    let bugfenderAppToken: String
    let segmentWriteKey: String
    let appseeApiKey: String
    let heapAppId: String
    let ouralabsKey = "5994e77086c6fcabc4bd5d5fe6c3e556"
    
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
                appseeApiKey = "90e5824e7a294045a992e56bbbb3f2f3"
                githubClientId = "fb2414c4535ddd7a86a1"
                githubClientSecret = "b4b16bca1611ee8318c56a61040ef1683d611a6a"
            case .Beta:
                upgradeURL = NSURL("https://taylrapp.com/beta")
                serverHostName = "s10-beta.herokuapp.com"
                bugfenderAppToken = "lO35cfZMdPxzIraCq4YFKISSKZ2EAIwe"
                segmentWriteKey = "SGEB9gVQGFYgeptFbtnETHCka8FCOuoc"
                heapAppId = "1572509943"
                appseeApiKey = "9a350ef30cb24154a547e8ebaebfe272"
                githubClientId = "d3d17fc593c45429cf29"     // this is wrong. need to make beta app.
                githubClientSecret = "4a6f949c772bfd87ae6e9be1ccc6ab21265de649"
            case .AppStore:
                upgradeURL = NSURL("https://taylrapp.com/download")
                serverHostName = "s10.herokuapp.com"
                bugfenderAppToken = "ow9JOdNYSo5iVqPUUAEbS8HfmwZqb1tQ"
                segmentWriteKey = "JPCrmGwQqlgohXoowBFSLwesir9Zn5Bv"
                heapAppId = "538095372"
                appseeApiKey = "a33413513aab4ad296f379481caf8d90"
                githubClientId = "d3d17fc593c45429cf29"
                githubClientSecret = "4a6f949c772bfd87ae6e9be1ccc6ab21265de649"
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