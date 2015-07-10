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
import OAuthSwift
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
    
    func linkNewService(type: Service.ServiceType, useWebView: Bool = true) -> RACSignal {
        switch type {
        case .Facebook:
            return linkFacebook()
        case .Instagram:
            return linkInstagram(authWebVC: useWebView ? makeAuthWebVC() : nil)
        }
    }
    
    func linkInstagram(authWebVC: AuthWebViewController? = nil) -> RACSignal {
        let subject = RACReplaySubject()
        let oauth = OAuth2Swift(
            consumerKey: env.instagramClientId,
            consumerSecret: "",
            authorizeUrl: "https://api.instagram.com/oauth/authorize",
            responseType: "token"
        )
        oauth.authorize_url_handler = authWebVC ?? oauth.authorize_url_handler
        oauth.authorizeWithCallbackURL(NSURL("\(env.audience.urlScheme)\(env.oauthCallbackPath)/instagram"),
            scope: "likes",
            state: generateStateWithLength(20) as String,
            success: { credential, response, parameters in
                subject.sendNext(nil)
            Async.main {
                Meteor.addService(.Instagram, accessToken: credential.oauth_token).subscribe(subject)
            }
            Log.debug("Successfulled received token from instagram")
        }, failure: { error in
            Log.error("Unable to link instagram", error)
            subject.sendError(error)
        })
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
                    Meteor.addService(.Facebook, accessToken: result.token.tokenString).subscribe(subject)
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
        let oauth1Keys = [
            "twitter",
            "flickr",
            "fitbit",
            "withings",
            "linkedin",
            "bitbucket",
            "smugmug",
            "intuit",
            "zaim",
            "tumblr",
        ]
        let oauth2Keys = [
            "github",
            "instagram",
            "foursquare",
            "dropbox",
            "dribbble",
            "salesforce",
            "google",
            "linkedin2",
        ]
        if let path = url.path where url.host == Globals.env.oauthCallbackPath {
            for key in oauth1Keys {
                if path.hasPrefix("/" + key) {
                    OAuth1Swift.handleOpenURL(url)
                    return true
                }
            }
            for key in oauth2Keys {
                if path.hasPrefix("/" + key) {
                    OAuth2Swift.handleOpenURL(url)
                    return true
                }
            }
        } else {
            // TODO: Should check explicitly whether it's a google request
            // Google provider is the only one with your.bundle.id url schema.
            OAuth2Swift.handleOpenURL(url)
            return true // For now return false because we don't do google yet
        }
        return false
    }
}

extension AuthWebViewController : OAuthSwiftURLHandlerType {
    @objc func handle(url: NSURL) {
        targetURL = url
        let rootVC = UIApplication.sharedApplication().keyWindow?.rootViewController
        rootVC?.presentViewController(self, animated: true, completion: nil)
    }
}