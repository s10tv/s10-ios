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
        allowedStates = [.Signup, .Waitlist, .Welcome]
        screenName = "FacebookPerm"
    }
    
    @IBAction func requestFacebookPermission(sender: AnyObject) {
        PKHUD.showActivity()
        Globals.accountService.login().subscribeError({ _ in
            PKHUD.hide()
            self.showAlert(LS(.fbPermDeniedAlertTitle),
                  message: LS(.fbPermDeniedAlertMessage))
        }, completed: { () -> Void in
            PKHUD.hide()
            self.performSegue(.FacebookPermToNotificationsPerm)
        })
    }
}

class NotificationsPermissionViewController : BaseViewController {
    
    override func commonInit() {
        allowedStates = [.Signup, .Waitlist, .Welcome]
        screenName = "NotificationsPerm"
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



class LocationPermissionViewController : BaseViewController {
    
    override func commonInit() {
        allowedStates = [.Signup, .Waitlist, .Welcome]
        screenName = "LocationPerm"
    }
    
    @IBAction func requestLocationPermission(sender: AnyObject) {
        Globals.locationService.requestPermission().deliverOnMainThread().subscribeCompleted {
            if Globals.flowService.currentState == .Waitlist {
                self.performSegue(.LocationPermToWaitlist)
            } else {
                self.performSegue(.LocationPermToLoading)
            }
        }
    }
}