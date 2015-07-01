//
//  Service.swift
//  S10
//
//  Created on 6/26/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Bond

@objc(Service)
public class Service : _Service {
    public enum ServiceType : String {
    case Facebook = "facebook"
    case Instagram = "instagram"
    }
    
    public private(set) lazy var dynUserDisplayName: Dynamic<String?> = {
        return self.dynValue(ServiceKeys.userDisplayName)
    }()
    
    public private(set) lazy var type: Dynamic<ServiceType?> = {
        return self.dynValue(ServiceKeys.serviceType).map { $0.map { ServiceType(rawValue: $0) } ?? nil }
    }()
    
}
