//
//  IntegrationViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/24/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation

public struct IntegrationViewModel {
//    public enum Status {
//        case NotLinked, Indexing, Linked, Error
//    }
    
    public let icon: Image
    public let title: String
    public let statusImage: Image?
    public let showSpinner: Bool
    
    public init(integration: Integration) {
        icon = Image(integration.iconUrl) ?? Image(UIImage(named: "ic-add")!)
        title = integration.linkedAccountName ?? integration.name ?? ""
        switch (integration.linkedAccountName, integration.isIndexing?.boolValue, integration.hasError?.boolValue) {
        case (.Some, .Some(false), .Some(false)):
            showSpinner = false
            statusImage = Image(UIImage(named: "ic-checkmark")!)
        case (.Some, .Some(true), .Some(false)):
            showSpinner = true
            statusImage = nil
        case (.Some, .Some(false), .Some(true)):
            showSpinner = false
            statusImage = Image(UIImage(named: "ic-warning")!)
        default:
            showSpinner = false
            statusImage = Image(UIImage(named: "ic-add")!)
        }
    }
}