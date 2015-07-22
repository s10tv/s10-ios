//
//  LinkAccountService.swift
//  S10
//
//  Created by Tony Xiao on 6/30/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Async
import FBSDKLoginKit
import Core

class LinkAccountService {

    let env: TaylrEnvironment
    
    init(env: TaylrEnvironment) {
        self.env = env
    }
    
    func makeAuthWebVC() -> AuthWebViewController {
        return UIStoryboard(name: "LinkAccount", bundle: nil).instantiateViewControllerWithIdentifier("AuthWeb") as! AuthWebViewController
    }
    
    func linkNewService(serviceType: ServiceType, useWebView: Bool = true) -> RACSignal {
        switch serviceType.documentID ?? "" {
        case "facebook":
            return linkFacebook()
        case "twitter":
            return RACSignal.empty()
        default:
            if let url = serviceType.dynURL.value {
                return linkWithWebview(url)
            }
            return RACSignal.empty()
        }
    }

    func linkWithWebview(url: NSURL) -> RACSignal {
        let subject = RACReplaySubject()
        let authWebVC = makeAuthWebVC()
        authWebVC.targetURL = url
        let rootVC = UIApplication.sharedApplication().keyWindow?.rootViewController
        rootVC?.presentViewController(authWebVC, animated: true, completion: nil)
        return subject.deliverOnMainThread()
    }
    
    func linkFacebook() -> RACSignal {
        let subject = RACReplaySubject()
        let fb = FBSDKLoginManager()
        let readPerms = [
            "user_about_me",
            "user_photos",
            "user_location",
            "user_work_history",
            "user_education_history",
            "user_birthday",
            "user_posts",
            // extended permissions
            "email"
        ]
        fb.logInWithReadPermissions(readPerms) { result, error in
            // Todo: check result.grantedPermissions is complete
            if error != nil {
                subject.sendError(error)
            } else if result.isCancelled {
                subject.sendError(nil) // TODO: Send explicit error
            } else {
                subject.sendNext(nil) // TODO: Used to signal progress, make more explicit
                Log.debug("Successfulled received token from facebook")
                Async.main {
                    Meteor.addService("facebook", accessToken: result.token.tokenString).subscribe(subject)
                }
            }
        }
        return subject.deliverOnMainThread()
    }
    
    // MARK: - App Delegate Hooks
    
    class func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    class func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        if FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url,
            sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }
        return false
    }
}
