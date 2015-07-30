//
//  IntegrationViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/24/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ObjectMapper

public struct IntegrationViewModel {
    public let id: String
    public let icon: Image
    public let name: String
    public let username: String?
    public let url: NSURL
    public let statusImage: Image?
    public let showSpinner: Bool
    
    init(integration: Integration) {
        id = integration.documentID!
        icon = integration.icon
        name = integration.name
        username = integration.username
        url = integration.url
        switch integration.status {
        case .Linked:
            showSpinner = false
            statusImage = Image(UIImage(named: "ic-checkmark")!)
        case .Busy:
            showSpinner = true
            statusImage = nil
        case .Error:
            showSpinner = false
            statusImage = Image(UIImage(named: "ic-warning")!)
        default:
            showSpinner = false
            statusImage = Image(UIImage(named: "ic-add")!)
        }
    }
}