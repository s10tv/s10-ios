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
    public enum Type : String {
    case Facebook = "facebook"
    case Instagram = "instagram"
    }
    
    public private(set) lazy var type: Dynamic<Type?> = {
        return self.dynValue(ServiceKeys.serviceType).map { $0.map { Type(rawValue: $0) } ?? nil }
    }()
    
}
