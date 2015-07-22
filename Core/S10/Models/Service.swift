//
//  Service.swift
//  S10
//
//  Created on 6/26/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import ReactiveCocoa
import Bond

@objc(Service)
public class Service : _Service {
    public private(set) lazy var dynUserDisplayName: Dynamic<String?> = {
        return self.dynValue(ServiceKeys.userDisplayName)
    }()
    
    public private(set) lazy var dynServiceType: PropertyOf<ServiceType?> = {
        return self.dyn(ServiceKeys.serviceType.rawValue).optional(ServiceType) |> readonly
    }()
    
    public private(set) lazy var userAvatarURL: Dynamic<NSURL?> = {
        return self.dynValue(ServiceKeys.avatar).map { NSURL.fromString($0) }
    }()
}
