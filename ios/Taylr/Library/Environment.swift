//
//  Environment.swift
//  Taylr
//
//  Created by Tony Xiao on 4/3/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import SimpleKeychain

public let IS_TARGET_IPHONE_SIMULATOR = (TARGET_IPHONE_SIMULATOR == 1)

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
        let keychain = A0SimpleKeychain(service: appId)
        let kDeviceId = "deviceId"
        var identifier = keychain.stringForKey(kDeviceId)
        if identifier == nil {
            identifier = UIDevice.currentDevice().identifierForVendor?.UUIDString ?? "r-\(NSUUID().UUIDString)"
            keychain.setString(identifier!, forKey: kDeviceId)
        }
        return identifier!
    }
    
    public var apsEnvironment: ApsEnvironment? {
        // Simulator
        if IS_TARGET_IPHONE_SIMULATOR {
            return nil
        }
         // Local / Crashlytics
        if let provisioningProfile = provisioningProfile {
            return provisioningProfile.apsEnvironment
        }
        // App Store / TestFlight
        return .Production
    }
    
    public var isRunningTestFlightBeta: Bool {
        if let fileName = NSBundle.mainBundle().appStoreReceiptURL?.lastPathComponent {
            return fileName == "sandboxReceipt"
        }
        return false
    }
    
    // MARK: - 
    
    public init(provisioningProfile: ProvisioningProfile?) {
        self.provisioningProfile = provisioningProfile
    }
    
    public convenience init() {
        self.init(provisioningProfile: ProvisioningProfile.embeddedProfile())
    }
    
}