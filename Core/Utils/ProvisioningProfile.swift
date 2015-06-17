//
//  ProvisioningProfile.swift
//  Taylr
//
//  Created by Tony Xiao on 4/3/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import TCMobileProvision

public class ProvisioningProfile {
    public enum Type {
        case Development, Enterprise, Adhoc, AppStore
    }
    public enum ApsEnvironment : String {
        case Sandbox = "development"
        case Production = "production"
    }
    
    public let info : [NSObject : AnyObject]
    
    public var name : String { return info["Name"]! as! String }
    public var entitlements : NSDictionary? {
        return info["Entitlements"] as? NSDictionary
    }
    public var type : Type {
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
    public var apsEnvironment : ApsEnvironment? {
        if let key = entitlements?["aps-environment"] as? String {
            return ApsEnvironment(rawValue: key)
        }
        return nil
    }
    
    public init(data: NSData) {
        info = TCMobileProvision(data: data).dict
    }
    
    public class func embeddedProfile() -> ProvisioningProfile? {
        let profileURL = NSBundle.mainBundle().bundleURL.URLByAppendingPathComponent("embedded.mobileprovision")
        if let data = NSData(contentsOfURL: profileURL) {
            return ProvisioningProfile(data: data)
        }
        return nil
    }
}