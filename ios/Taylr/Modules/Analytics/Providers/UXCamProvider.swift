//
//  UXCamProvider.swift
//  Taylr
//
//  Created by Tony Xiao on 11/22/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import Intercom
//#if Release
import UXCam
//#endif

public class UXCamProvider : NSObject, AnalyticsProvider {
    var context: AnalyticsContext!

    init(apiKey: String) {
        UXCam.startWithKey(apiKey)
    }
    
    func login(isNewUser: Bool) {
        UXCam.tagUsersName(context.userId)
    }
    
    func logout() {
        UXCam.tagUsersName(nil)
    }
}
