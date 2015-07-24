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
    public let title: String
    public let url: NSURL
    public let statusImage: Image?
    public let showSpinner: Bool
    
    public init(integration: Integration) {
        id = integration.documentID!
        icon = Mapper<Image>().map(integration.icon)!
        title = integration.username ?? integration.name
        url = NSURL(integration.url)
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
    }
}