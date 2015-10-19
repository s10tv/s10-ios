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

let kMIMETypeVideo = "video/mp4"
let kMIMETypeThumbnail = "image/jpeg+preview"
let kMIMETypeMetadata = "application/json+imageSize"

extension LYRMessage {
    public var messageParts: [LYRMessagePart] {
        return parts.map { $0 as! LYRMessagePart }
    }
    public var videoPart: LYRMessagePart? {
        return messageParts.filter { $0.MIMEType == kMIMETypeVideo }.first
    }
    public var thumbnailPart: LYRMessagePart? {
        return messageParts.filter { $0.MIMEType == kMIMETypeThumbnail }.first
    }
    public var metadataPart: LYRMessagePart? {
        return messageParts.filter { $0.MIMEType == kMIMETypeMetadata }.first
    }
}

extension LYRMessagePart {
    
    public func asImage() -> UIImage? {
        return (data as NSData?).flatMap { UIImage(data: $0) }
    }
    
    public func asJson() -> AnyObject? {
        return (data as NSData?).flatMap { try? NSJSONSerialization.JSONObjectWithData($0, options: []) }
    }
}

extension LYRContentTransferType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Upload: return "Upload"
        case .Download: return "Download"
        }
    }
}

extension LYRClient {
    var isAuthenticated: Bool {
        return authenticatedUserID != nil
    }
    
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
}

// MARK: -

extension LYRClient {
    
    func connectAndAuthenticateAgainstStaging() -> SignalProducer<String, NSError> {
        return connect().flatMap(.Concat) {
            self.requestAuthenticationNonce()
            }.flatMap(.Concat) { nonce in
                self.requestStagingIdentityToken(nonce)
            }.flatMap(.Concat) { identityToken in
                self.authenticate(identityToken)
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