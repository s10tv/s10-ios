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

class LinkedAccountService {

    let env: TaylrEnvironment
    let authWebVC: AuthWebViewController
    var presentingVC: UIViewController?
    
    init(authWebVC: AuthWebViewController) {
        self.authWebVC = authWebVC
        env = Globals.env
    }
    
    func linkNewService(type: Service.ServiceType, presentingViewController: UIViewController) {
        switch type {
        case .Facebook:
            break
        case .Instagram:
            linkInstagram(presentingViewController)
        }
    }
    
    func linkInstagram(presentingViewController: UIViewController) {
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
            println("oauth_token:\(credential.oauth_token)")
        }, failure: { error in
            Log.error("Unable to link instagram", error)
        })
    }
}

extension LinkedAccountService : OAuthSwiftURLHandlerType {
    @objc func handle(url: NSURL) {
        authWebVC.targetURL = url
        presentingVC?.presentViewController(authWebVC, animated: true, completion: nil)
    }
}