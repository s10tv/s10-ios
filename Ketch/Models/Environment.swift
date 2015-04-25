//
//  Environment.swift
//  Ketch
//
//  Created by Tony Xiao on 4/3/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class Environment {
    enum Audience {
        case Dev, Beta, AppStore
        var urlScheme: String {
            switch self {
            case .Dev: return "ketch-dev://"
            case .Beta: return "ketch-beta://"
            case .AppStore: return "ketch://"
            }
        }
        var installed: Bool {
            return UIApplication.sharedApplication().canOpenURL(NSURL(urlScheme))
        }
    }
    
    let audience : Audience
    let provisioningProfile : ProvisioningProfile?
    let termsAndConditionURL = NSURL("http://ketchtheone.com/terms")
    let privacyURL = NSURL("http://ketchtheone.com/privacy")
    let notPickyExitURL = NSURL("http://tinder.com/")
    let upgradeURL = NSURL("http://ketchtheone.com/download")
    let serverProtocol = "wss"
    let serverHostName : String
    var serverURL : NSURL {
        return NSURL("\(serverProtocol)://\(serverHostName)/websocket")
    }
    var appId: String {
        return NSBundle.mainBundle().bundleIdentifier!
    }
    var version: String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as String
    }
    var build: String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey) as String
    }
    var deviceId: String {
        return UIDevice.currentDevice().getPersistentIdentifier()
    }
    
    let crashlyticsAPIKey = "4cdb005d0ddfebc8865c0a768de9b43c993e9113"
    let bugfenderAppToken: String
    let segmentWriteKey: String
    let heapAppId: String
    
    init(audience: Audience, provisioningProfile: ProvisioningProfile?) {
        self.audience = audience
        self.provisioningProfile = provisioningProfile
        switch audience {
            case .Dev:
                serverHostName = "ketch-dev.herokuapp.com"
//                serverHostName = "10.1.10.44:3000"
//                serverHostName = "ketch-beta.herokuapp.com"
                bugfenderAppToken = "RBsiKkpkyiXUW2Sk50JTKTKUYlNpXsFn"
                segmentWriteKey = "vfnxR5SsgYkNQqRznBWHXDp2LMFkUNTv"
                heapAppId = "2150081452"
            case .Beta:
                serverHostName = "ketch-beta.herokuapp.com"
                bugfenderAppToken = "lO35cfZMdPxzIraCq4YFKISSKZ2EAIwe"
                segmentWriteKey = "SGEB9gVQGFYgeptFbtnETHCka8FCOuoc"
                heapAppId = "1572509943"
            case .AppStore:
                serverHostName = "ketch.herokuapp.com"
                bugfenderAppToken = "ow9JOdNYSo5iVqPUUAEbS8HfmwZqb1tQ"
                segmentWriteKey = "JPCrmGwQqlgohXoowBFSLwesir9Zn5Bv"
                heapAppId = "538095372"
        }
    }
    
    class func configureFromEmbeddedProvisioningProfile() -> Environment {
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
        return Environment(audience: audienceFromProfile(profile), provisioningProfile: profile)
    }
}