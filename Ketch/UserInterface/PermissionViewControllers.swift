//
//  PermissionViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 4/3/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import CoreLocation
import PKHUD

class FacebookPermissionViewController : BaseViewController {
    
    override func commonInit() {
        allowedStates = [.Signup]
    }
    
    @IBAction func requestFacebookPermission(sender: AnyObject) {
        PKHUD.showActivity()
        Account.login().subscribeError({ _ in
            PKHUD.hide()
            self.showAlert(LS(R.Strings.fbPermDeniedAlertTitle),
                  message: LS(R.Strings.fbPermDeniedAlertMessage))
        }, completed: { () -> Void in
            PKHUD.hide()
            self.performSegue(.FacebookPermToNotificationsPerm)
        })
    }
}

class NotificationsPermissionViewController : BaseViewController {
    
    override func commonInit() {
        allowedStates = [.Signup]
    }
    
    @IBAction func requestNotificationsPermission(sender: AnyObject) {
        let settings = UIUserNotificationSettings(forTypes:
            UIUserNotificationType.Badge |
                UIUserNotificationType.Alert |
                UIUserNotificationType.Sound,
            categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        listenForNotification(AppDidRegisterUserNotificationSettings).take(1).subscribeNextAs { (note: NSNotification) in
            let settings = note.object as UIUserNotificationSettings
            self.performSegue(.NotificationsPermToLocationPerm)
        }
    }
}



class LocationPermissionViewController : BaseViewController, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    
    override func commonInit() {
        allowedStates = [.Signup]
    }
    
    @IBAction func requestLocationPermission(sender: AnyObject) {
        switch CLLocationManager.authorizationStatus() {
        case .NotDetermined:
            manager.delegate = self
            manager.requestWhenInUseAuthorization()
        default:
            finishLocationRequest()
        }
    }
    
    func finishLocationRequest() {
        if Flow.currentState == .Waitlist {
            performSegue(.LocationPermToWaitlist)
        } else {
            performSegue(.LocationPermToLoading)
        }
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        Log.debug("Location status is \(status)")
        finishLocationRequest()
    }
}