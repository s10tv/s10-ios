//
//  UXCamProvider.swift
//  Taylr
//
//  Created by Tony Xiao on 11/22/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import Intercom
#if Release
    import UXCam
#endif

public class UXCamProvider : NSObject, AnalyticsProvider {
    
    init(apiKey: String) {
        #if Release
            UXCam.startWithKey(apiKey)
        #endif
    }
    
    #if Release
    func identifyUser(userId: String) {
    }
    
    func track(event: String!, properties: [NSObject : AnyObject]?) {
    }
    #endif
}
