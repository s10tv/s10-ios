//
//  LocationService.swift
//  Ketch
//
//  Created by Tony Xiao on 4/18/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import INTULocationManager
import ReactiveCocoa

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
        manager.requestLocationWithDesiredAccuracy(.None, timeout: 0.01, delayUntilAuthorized: true) { _, _, _ in
            subject.sendCompleted()
        }
        return subject
    }
    
    func updateLatestLocationIfAvailable() {
        if status != .Available {
            return
        }
        manager.requestLocationWithDesiredAccuracy(.Neighborhood, timeout: 10) { location, accuracy, status in
            if location != nil {
                self.meteorService.updateDeviceLocation(location)
            }
        }
    }
}