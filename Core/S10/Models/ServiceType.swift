//
//  ServiceType.swift
//  S10
//
//  Created on 1/20/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import ReactiveCocoa

@objc(ServiceType)
public class ServiceType: _ServiceType {
    
    public var name: String? {
        return documentID?.capitalizedString
    }

    public private(set) lazy var dynIconURL: PropertyOf<NSURL?> = {
        return self.dyn(ServiceTypeKeys.icon.rawValue).optional(String) |> map { NSURL.fromString($0) }
    }()
    
    public private(set) lazy var dynURL: PropertyOf<NSURL?> = {
        return self.dyn(ServiceTypeKeys.url.rawValue).optional(String) |> map { NSURL.fromString($0) }
    }()

}
