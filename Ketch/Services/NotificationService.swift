//
//  NotificationService.swift
//  Ketch
//
//  Created by Tony Xiao on 4/3/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import ReactiveCocoa

public let NC = NSNotificationCenter.defaultCenter() // Intentionally global variable

enum NotificationName : String {
    case DidRegisterUserNotificationSettings = "DidRegisterUserNotificationSettings"
}

extension NSNotificationCenter {
    func postNotification(name: NotificationName, object: AnyObject?) {
        postNotificationName(name.rawValue, object: object)
    }
}

extension NSObject {
    func listenForNotification(name: NotificationName) -> RACSignal {
        return listenForNotification(name.rawValue)
    }
}