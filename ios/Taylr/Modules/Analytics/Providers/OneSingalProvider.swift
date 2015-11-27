//
//  OneSingalProvider.swift
//  Taylr
//
//  Created by Tony Xiao on 11/27/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation

class OneSingalProvider : NSObject, AnalyticsProvider {
    var context: AnalyticsContext!
    
    let oneSignal: OneSignal
    
    init(appId: String, launchOptions: [NSObject: AnyObject]?) {
        oneSignal = OneSignal(launchOptions: launchOptions, appId: appId, handleNotification: nil, autoRegister: false)
        oneSignal.enableInAppAlertNotification(true)
        OneSignal.setDefaultClient(oneSignal)
    }

    func login(isNewUser: Bool) {
    }
    
    func logout() {
    }
}