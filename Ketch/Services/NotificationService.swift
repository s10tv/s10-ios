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
    case WillLoginToMeteor = "WillLoginToMeteor"
    case DidSucceedLoginToMeteor = "DidSucceedLoginToMeteor"
    case DidFailLoginToMeteor = "DidFailLoginToMeteor"
    case CandidatesUpdated = "CandidatesUpdated"
    case DidRegisterUserNotificationSettings = "DidRegisterUserNotificationSettings"
    case DidSubmitGame = "DidSubmitGame"
    case DidReceiveGameResult = "DidReceiveGameResult"
}

extension NSNotificationCenter.Proxy {
    func listen(name: NotificationName, object: AnyObject? = nil, block: (NSNotification) -> ()) {
        listen(name.rawValue, object: object, block: block)
    }
}

extension NSNotificationCenter {
    
    func postNotification(name: NotificationName, object: AnyObject? = nil, userInfo: [NSObject: AnyObject]? = nil) {
        println("Posting notification \(name.rawValue)")
        postNotificationName(name.rawValue, object: object, userInfo: userInfo)
    }
    
    func addObserver(observer: AnyObject, selector: Selector, name: NotificationName, object: AnyObject? = nil) {
        addObserver(observer, selector: selector, name: name.rawValue, object: object)
    }
}

extension NSObject {
    func listenForNotification(name: NotificationName) -> RACSignal {
        return listenForNotification(name.rawValue)
    }
}