//
//  ServiceViewModel.swift
//  S10
//
//  Created by Tony Xiao on 6/30/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Bond
import ReactiveCocoa

public struct ServiceViewModel {
    public let service: Service
    public let name: PropertyOf<String>
    public let serviceIconURL: PropertyOf<NSURL?>
    public let userDisplayName: Dynamic<String>
    
    public init(_ service: Service) {
        self.service = service
        name = service.dynServiceType |> map {
            return $0?.name ?? ""
        }
        serviceIconURL = service.dynServiceType |> map {
            return $0?.dynIconURL.value
        }
        userDisplayName = service.dynUserDisplayName.map { $0 ?? "" }
    }
}