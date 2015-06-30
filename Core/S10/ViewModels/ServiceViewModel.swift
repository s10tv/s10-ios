//
//  ServiceViewModel.swift
//  S10
//
//  Created by Tony Xiao on 6/30/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Bond

public struct ServiceViewModel {
    let service: Service
    public let serviceIcon: Dynamic<UIImage?>
    public let userDisplayName: Dynamic<String>
    
    public init(_ service: Service) {
        self.service = service
        serviceIcon = service.type.map {
            if let type = $0 {
                switch type {
                    // TODO: Figure out ways to avoid hardcoding image name
                case .Facebook: return UIImage(named: "ic-facebook")
                case .Instagram: return UIImage(named: "ic-instagram")
                }
            }
            return nil
        }
        userDisplayName = service.dynUserDisplayName.map { $0 ?? "" }
    }
}