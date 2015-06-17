//
//  Environment.swift
//  Taylr
//
//  Created by Tony Xiao on 4/3/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation

public class Environment {
    public let provisioningProfile : ProvisioningProfile?
    public var appId: String {
        return NSBundle.mainBundle().bundleIdentifier!
    }
    public var version: String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
    }
    public var build: String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as! String
    }
    public var deviceId: String {
        return UIDevice.currentDevice().getPersistentIdentifier()
    }
    
    public init(provisioningProfile: ProvisioningProfile?) {
        self.provisioningProfile = provisioningProfile
    }
}