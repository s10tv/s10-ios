//
//  PermissionViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 4/3/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import CoreLocation

@objc(PermissionViewController)
class PermissionViewController : BaseViewController {
    
    var permissionType : PermissionType!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var explanationLabel: DesignableLabel!
    @IBOutlet weak var mainButton: DesignableButton!
    var locManager : CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = permissionType.image
        explanationLabel.rawText = permissionType.explanation
        mainButton.text = permissionType.buttonTitle
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.matches(.NotificationsPermToLocationPerm) {
            (segue.destinationViewController as PermissionViewController).permissionType = .Location
        }
    }
    
    @IBAction func mainAction(sender: AnyObject) {
        switch permissionType! {
        case .Notifications:
            requestNotificationsPermission()
        case .Location:
            requestLocationPermission()
        default:
            break
        }
    }
    
    func requestFacebookPermission() {
        Core.loginWithUI()
    }
    
    func requestNotificationsPermission() {
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
    
    func requestLocationPermission() {
        locManager = CLLocationManager()
        locManager?.delegate = self
        locManager?.requestWhenInUseAuthorization()
    }
}

extension PermissionViewController : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        rootVC.rootView.animateHorizon(ratio: 0.6)
        performSegue(.LocationPermToWaitlist)
//        rootVC.finishSignup(self)
    }
}
