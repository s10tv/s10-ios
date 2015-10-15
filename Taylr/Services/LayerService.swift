//
//  LayerService.swift
//  S10
//
//  Created by Tony Xiao on 10/14/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import LayerKit
import Core


public class LayerService {
    
    let meteor: MeteorService
    let layerClient: LYRClient
    
    init(layerAppID: NSURL, meteor: MeteorService) {
        self.meteor = meteor
        layerClient = LYRClient(appID: layerAppID)
    }
    
    // TODO: Careful this method if not disposed will retain self
    func connectAndKeepUserInSync() -> Disposable {
        return combineLatest(
            layerClient.connect(),
            meteor.userIdProducer().promoteErrors(NSError)
        ).flatMap(.Latest) { _, userId in
            return self.syncWithUser(userId)
        }.start(Event.sink(error: { error in
            Log.error("Unable to update user in Layer session", error)
        }, next: { userId in
            Log.info("Updated user in Layer session userId=\(userId)")
        }))
    }
    
    // MARK: -
    
    private func syncWithUser(userId: String?) -> SignalProducer<String?, NSError> {
        if let userId = userId {
            return self.authenticate(userId).map { $0 }
        } else {
            return self.deauthenticate().map { _ in nil }
        }
    }
    
    private func authenticate(userId: String) -> SignalProducer<String, NSError> {
        if let layerUserId = layerClient.authenticatedUserID where layerUserId == userId {
            return SignalProducer(value: userId)
        } else if layerClient.isAuthenticated {
            return layerClient.deauthenticate().then(authenticate(userId))
        }
        return layerClient.requestAuthenticationNonce().flatMap(.Concat) { nonce in
            self.meteor.layerAuth(nonce).producer
        }.flatMap(.Concat) { identityToken in
            self.layerClient.authenticate(identityToken)
        }
    }
    
    private func deauthenticate() -> SignalProducer<(), NSError> {
        if !layerClient.isAuthenticated {
            return SignalProducer(value: ())
        }
        return layerClient.deauthenticate()
    }
}