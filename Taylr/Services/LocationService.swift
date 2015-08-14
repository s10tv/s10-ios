//
//  LocationService.swift
//  Taylr
//
//  Created by Tony Xiao on 4/18/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import INTULocationManager
import ReactiveCocoa
import Core

class LocationService {
    private let manager = INTULocationManager.sharedInstance()
    private let meteorService: MeteorService
    var status: INTULocationServicesState {
        return INTULocationManager.locationServicesState()
    }
    
    init(meteorService: MeteorService) {
        self.meteorService = meteorService
    }
    
    func requestPermission() -> RACSignal {
        if status != .NotDetermined {
            return RACSignal.empty()
        }
        let subject = RACSubject()
        // Small timeout to hack the fact that manager does have perm request API
        manager.requestLocationWithDesiredAccuracy(.City, timeout: 0.01, delayUntilAuthorized: true) { _, _, status in
            if status == INTULocationStatus.ServicesDenied {
                Globals.analyticsService.track("Location Service Denied")
            } else if status == INTULocationStatus.ServicesRestricted {
                Globals.analyticsService.track("Location Service Restricted")
            } else if status == INTULocationStatus.ServicesDisabled {
                Globals.analyticsService.track("Location Service Disabled")
            } else if status == INTULocationStatus.Error {
                Globals.analyticsService.track("Location Service Error")
            } else if status == INTULocationStatus.ServicesNotDetermined {
                Globals.analyticsService.track("Location Service Not Determined")
            }

            subject.sendCompleted()
        }
        return subject
    }
    
    func updateLatestLocationIfAvailable() {
        if status != .Available {
            return
        }
        manager.requestLocationWithDesiredAccuracy(.Neighborhood, timeout: 10) { location, accuracy, status in
            Log.debug("Received location: \(location) accuracy: \(accuracy.rawValue) status: \(status.rawValue)")
            if location != nil {
                self.meteorService.updateDeviceLocation(location)
            }
        }
    }
}