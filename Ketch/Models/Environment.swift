//
//  Environment.swift
//  Ketch
//
//  Created by Tony Xiao on 4/3/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

let Env = Environment.configureFromEmbeddedProvisioningProfile()

class Environment {
    enum Audience {
        case Dev, Beta, AppStore
    }
    
    let audience : Audience
    let provisioningProfile : ProvisioningProfile?
    let crashlyticsAPIKey = "4cdb005d0ddfebc8865c0a768de9b43c993e9113"
    let serverProtocol = "ws" // TODO: Change to websocket secure
    let serverHostName : String
    var serverURL : NSURL {
        return NSURL(string: "\(serverProtocol)://\(serverHostName)/websocket")!
    }
    var appID : String {
        return NSBundle.mainBundle().infoDictionary?["CFBundleIdentifier"] as String
    }
    
    init(audience: Audience, provisioningProfile: ProvisioningProfile?) {
        self.audience = audience
        self.provisioningProfile = provisioningProfile
        switch audience {
            case .Dev:
                serverHostName = "ketch-dev.herokuapp.com" // "localhost:3000"
            case .Beta:
                serverHostName = "ketch-beta.herokuapp.com"
            case .AppStore:
                serverHostName = "ketch.herokuapp.com"
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