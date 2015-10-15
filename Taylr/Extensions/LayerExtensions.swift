//
//  LayerExtensions.swift
//  S10
//
//  Created by Tony Xiao on 10/14/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import LayerKit
import ReactiveCocoa
import Core

extension LYRClient {
    func connectAndAuthenticate() -> SignalProducer<String, NSError> {
        return connect().flatMap(.Concat) {
            self.requestAuthenticationNonce()
        }.flatMap(.Concat) { nonce in
            self.requestStagingIdentityToken(nonce)
        }.flatMap(.Concat) { identityToken in
            self.authenticate(identityToken)
        }
    }
}

extension LYRClient {
    func connect() -> SignalProducer<(), NSError> {
        return SignalProducer { sink, disposable in
            self.connectWithCompletion { success, error in
                if success {
                    sendNextAndCompleted(sink, ())
                } else {
                    sendError(sink, error)
                }
            }
        }
    }
    
    func requestAuthenticationNonce() -> SignalProducer<String, NSError> {
        return SignalProducer { sink, disposable in
            self.requestAuthenticationNonceWithCompletion { nonce, error in
                if let nonce = nonce {
                    sendNextAndCompleted(sink, nonce)
                } else {
                    sendError(sink, error)
                }
            }
        }
    }
    
    func authenticate(identityToken: String) -> SignalProducer<String, NSError> {
        return SignalProducer { sink, disposable in
            self.authenticateWithIdentityToken(identityToken) { remoteUserID, error in
                if let remoteUserID = remoteUserID {
                    sendNextAndCompleted(sink, remoteUserID)
                } else {
                    sendError(sink, error)
                }
            }
        }
    }
    
    func deauthenticate() -> SignalProducer<(), NSError> {
        return SignalProducer { sink, disposable in
            self.deauthenticateWithCompletion { success, error in
                if success {
                    sendNextAndCompleted(sink, ())
                } else {
                    sendError(sink, error)
                }
            }
        }
    }
    
    func synchronizeWithRemoteNotification(userInfo: [NSObject : AnyObject]) -> SignalProducer<[AnyObject], NSError> {
        return SignalProducer { sink, disposable in
            let handled = self.synchronizeWithRemoteNotification(userInfo) { changes, error in
                if let changes = changes {
                    sendNextAndCompleted(sink, changes)
                } else {
                    sendError(sink, error)
                }
            }
            if !handled {
                sendInterrupted(sink)
            }
        }
    }
    
    func requestStagingIdentityToken(nonce: String) -> SignalProducer<String, NSError> {
//        let userID = "12123 123 123 12"
//        let appID = "1232131 13 12 2232"
        return SignalProducer { sink, disposable in
//            let identityTokenURL = NSURL("https://layer-identity-provider.herokuapp.com/identity_tokens")
//            var request = NSMutableURLRequest(URL: identityTokenURL)
//            request.HTTPMethod = "POST"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.setValue("application/json", forHTTPHeaderField: "Accept")
//            var parameters: [NSObject : AnyObject] = ["app_id": appID, "user_id": userID, "nonce": nonce]
//            
//            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(parameters, options: [])
//            var sessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
//            var session = NSURLSession(configuration: sessionConfiguration)
//            
//            session.dataTaskWithRequest(request) { data, response, error in
//                if let error = error {
//                    sendError(sink, error)
//                    return
//                }
//                let responseObject: [NSObject : AnyObject] = try? NSJSONSerialization.JSONObjectWithData(data!, options: [])
//                if !responseObject.valueForKey("error") {
//                    var identityToken: String = responseObject["identity_token"]
//                    completion(identityToken, nil)
//                }
//                else {
//                    var domain: String = "layer-identity-provider.herokuapp.com"
//                    var code: Int = responseObject["status"].integerValue()
//                    var userInfo: [NSObject : AnyObject] = [NSLocalizedDescriptionKey: "Layer Identity Provider Returned an Error.", NSLocalizedRecoverySuggestionErrorKey: "There may be a problem with your APPID."]
//                    var error: NSErrorPointer = NSError(domain: domain, code: code, userInfo: userInfo)
//                    completion(nil, error)
//                }
//            }).resume()

        }
    }
}