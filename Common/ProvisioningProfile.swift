//
//  ProvisioningProfile.swift
//  Taylr
//
//  Created by Tony Xiao on 4/3/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import TCMobileProvision

class ProvisioningProfile {
    enum Type {
        case Development, Enterprise, Adhoc, AppStore
    }
    enum ApsEnvironment : String {
        case Sandbox = "development"
        case Production = "production"
    }
    
    let info : [NSObject : AnyObject]
    
    var name : String { return info["Name"]! as! String }
    var entitlements : NSDictionary? {
        return info["Entitlements"] as? NSDictionary
    }
    var type : Type {
        let getTaskAllow = entitlements?["get-task-allow"] as? Bool ?? false
        let hasProvisionedDevices = info["ProvisionedDevices"] != nil
        let provisionAllDevices = info["ProvisionsAllDevices"] as? Bool ?? false
        switch (getTaskAllow, hasProvisionedDevices, provisionAllDevices) {
            case (true, true, false): return .Development
            case (false, false, true): return .Enterprise
            case (false, true, false): return .Adhoc
            case (false, false, false): return .AppStore
            default: return .AppStore
        }
    }
    var apsEnvironment : ApsEnvironment? {
        if let key = entitlements?["aps-environment"] as? String {
            return ApsEnvironment(rawValue: key)
        }
        return nil
    }
    
    init(data: NSData) {
        info = TCMobileProvision(data: data).dict
    }
    
    class func embeddedProfile() -> ProvisioningProfile? {
        let profileURL = NSBundle.mainBundle().bundleURL.URLByAppendingPathComponent("embedded.mobileprovision")
        if let data = NSData(contentsOfURL: profileURL) {
            return ProvisioningProfile(data: data)
        }
        return nil
    }
}