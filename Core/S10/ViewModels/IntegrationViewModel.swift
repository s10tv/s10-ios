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
    public let icon: Image
    public let title: String
    public let statusImage: Image?
    public let showSpinner: Bool
    public let url: NSURL?
    
    public init(integration: Integration) {
        icon = Mapper<Image>().map(integration.icon)!
        title = integration.username ?? integration.name
        switch integration.status {
        case "linked":
            showSpinner = false
            statusImage = Image(UIImage(named: "ic-checkmark")!)
        case "busy":
            showSpinner = true
            statusImage = nil
        case "error":
            showSpinner = false
            statusImage = Image(UIImage(named: "ic-warning")!)
        default:
            showSpinner = false
            statusImage = Image(UIImage(named: "ic-add")!)
        }
        url = NSURL(string: integration.url ?? "")
    }
}