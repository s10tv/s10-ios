//
//  ProvisioningProfile.swift
//  Taylr
//
//  Created by Tony Xiao on 4/3/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import DTFoundation
import CocoaLumberjack

public enum ApsEnvironment : String {
    case Sandbox = "development"
    case Production = "production"
}

public class ProvisioningProfile {
    public enum Type {
        case Development, Enterprise, Adhoc, AppStore
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
        info = InfoParser(data: data).parse()!
    }
    
    public class func embeddedProfile() -> ProvisioningProfile? {
        let profileURL = NSBundle.mainBundle().bundleURL.URLByAppendingPathComponent("embedded.mobileprovision")
        if let data = NSData(contentsOfURL: profileURL) {
            if data.length > 0 {
                return ProvisioningProfile(data: data)
            } else {
                // https://fabric.io/s10-inc2/ios/apps/tv.s10.taylr/issues/5660f702f5d3a7f76b129394/sessions/fb503306d51f47dcabdbcd42cc1a88e7
                DDLogError("Provisioning profile data unexpectedly has length=0")
            }
        }
        return nil
    }
    
    class InfoParser : NSObject, DTASN1ParserDelegate {
        private let asn1Parser: DTASN1Parser
        private var currentObjectIdentifier: String?
        private var parsedDict: [NSObject: AnyObject]?

        init(data: NSData) {
            asn1Parser = DTASN1Parser(data: data)
            super.init()
            asn1Parser.delegate = self
        }
        
        func parse() -> [NSObject: AnyObject]? {
            asn1Parser.parse()
            return parsedDict
        }
        
        @objc func parser(parser: DTASN1Parser!, foundObjectIdentifier objIdentifier: String!) {
            currentObjectIdentifier = objIdentifier
        }
        
        @objc func parser(parser: DTASN1Parser!, foundData data: NSData!) {
            if currentObjectIdentifier == "1.2.840.113549.1.7.1" {
                let option = NSPropertyListReadOptions(rawValue: NSPropertyListMutabilityOptions.Immutable.rawValue)
                do {
                    try parsedDict = NSPropertyListSerialization.propertyListWithData(data, options: option, format: nil) as? [NSObject: AnyObject]
                } catch {
                    assert(parsedDict != nil, "Failed to parse dict \(error)")
                }
                currentObjectIdentifier = nil
            }
        }
    }
}