//
//  Environment.swift
//  Ketch
//
//  Created by Tony Xiao on 4/3/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

let Env = Environment()

class Environment {
    enum Audience {
        case Dev, Beta, AppStore
    }
    let crashlyticsAPIKey = "4cdb005d0ddfebc8865c0a768de9b43c993e9113"
    let provisioningProfile = ProvisioningProfile.embeddedProfile()
    let audience : Audience
    let serverHostName = "ketch-dev.herokuapp.com"
//    let serverHostname = "localhost:3000"
    let serverProtocol = "ws" // wss
    
    init() {
        audience = .Dev
    }
    
    var serverURL : NSURL {
        return NSURL(string: "\(serverProtocol)://\(serverHostName)/websocket")!
    }
    var appID : String {
        return NSBundle.mainBundle().infoDictionary?["CFBundleIdentifier"] as String
    }
}