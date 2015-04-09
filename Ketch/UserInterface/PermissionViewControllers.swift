//
//  PermissionViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 4/3/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import CoreLocation

class FacebookPermissionViewController : BaseViewController {
    
    @IBAction func requestFacebookPermission() {
        Core.loginWithUI()
    }
}

class NotificationsPermissionViewController : BaseViewController {
    
    @IBAction func requestNotificationsPermission() {
        let settings = UIUserNotificationSettings(forTypes:
            UIUserNotificationType.Badge |
                UIUserNotificationType.Alert |
                UIUserNotificationType.Sound,
            categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        listenForNotification(.DidRegisterUserNotificationSettings).take(1).subscribeNextAs { (note: NSNotification) in
            let settings = note.object as UIUserNotificationSettings
            self.performSegue(.NotificationsPermToLocationPerm)
        }
    }
}

class LocationPermissionViewController : BaseViewController, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    
    @IBAction func requestLocationPermission() {
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
//        if User.currentUser()?.vetted == "yes" {
//            navigationController?.popToRootViewControllerAnimated(true)
//        } else {
//            performSegue(.LocationPermToWaitlist)
//        }
    }
}