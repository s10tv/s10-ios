//
//  LinkedAccountService.swift
//  S10
//
//  Created by Tony Xiao on 6/30/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import OAuthSwift
import Core
import ReactiveCocoa

class LinkedAccountService {

    let env: TaylrEnvironment
    let authWebVC: AuthWebViewController
    var presentingVC: UIViewController?
    
    init(authWebVC: AuthWebViewController) {
        self.authWebVC = authWebVC
        env = Globals.env
    }
    
    func linkNewService(type: Service.ServiceType, presentingViewController: UIViewController) -> RACSignal {
        switch type {
        case .Facebook:
            break
        case .Instagram:
            return linkInstagram(presentingViewController)
        }
        return RACSignal.empty()
    }
    
    func linkInstagram(presentingViewController: UIViewController) -> RACSignal {
        let subject = RACReplaySubject()
        presentingVC = presentingViewController
        let oauth = OAuth2Swift(
            consumerKey: env.instagramClientId,
            consumerSecret: "",
            authorizeUrl: "https://api.instagram.com/oauth/authorize",
            responseType: "token"
        )
        oauth.authorize_url_handler = self
        oauth.authorizeWithCallbackURL(NSURL("\(env.audience.urlScheme)\(env.oauthCallbackPath)/instagram"),
            scope: "likes",
            state: generateStateWithLength(20) as String,
            success: { credential, response, parameters in
                subject.sendNext(nil)
            dispatch_async(dispatch_get_main_queue()) {
                Meteor.addService("instagram", accessToken: credential.oauth_token).subscribe(subject)
            }
            Log.debug("Successfulled received token from instagram")
        }, failure: { error in
            Log.error("Unable to link instagram", error)
            subject.sendError(error)
        })
        return subject.deliverOnMainThread()
    }
}

extension LinkedAccountService : OAuthSwiftURLHandlerType {
    @objc func handle(url: NSURL) {
        authWebVC.targetURL = url
        presentingVC?.presentViewController(authWebVC, animated: true, completion: nil)
    }
}