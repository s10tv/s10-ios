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

public class LayerService: NSObject {
    
    let meteor: MeteorService
    let unreadCount = MutableProperty(UInt(0))
    let unreadQueryController: LYRQueryController
    public let layerClient: LYRClient
    
    public init(layerAppID: NSURL, meteor: MeteorService) {
        self.meteor = meteor
        layerClient = LYRClient(appID: layerAppID)
        let query = LYRQuery(queryableClass: LYRConversation.self)
        query.predicate = LYRPredicate(property: "hasUnreadMessages", predicateOperator: .IsEqualTo, value: true)
        unreadQueryController = (try? layerClient.queryControllerWithQuery(query, error: ()))!
        super.init()
        unreadQueryController.delegate = self
        _ = try? unreadQueryController.execute()
        unreadCount.value = unreadQueryController.count()
        layerClient.autodownloadMaximumContentSize = 50 * 1024 * 1024 // 50mb
        layerClient.backgroundContentTransferEnabled = true
        layerClient.diskCapacity = 300 * 1024 * 1024 // 300mb
    }
    
    // TODO: Careful this method if not disposed will retain self
    public func connectAndKeepUserInSync() -> Disposable {
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
    
    func findConversationsWithUserId(userId: String) -> [LYRConversation] {
        do {
            let query = LYRQuery(queryableClass: LYRConversation.self)
            query.predicate = LYRPredicate(property: "participants", predicateOperator: .IsIn, value: userId)
            return try layerClient.executeQuery(query).map { $0 as! LYRConversation }
        } catch {
            return []
        }
    }
    
    func conversationWithUser(user: User) -> LYRConversation {
        do {
            return try layerClient.newConversationWithParticipants(Set([user.documentID!]), options: [LYRConversationOptionsDistinctByParticipantsKey: true])
        } catch let error as NSError {
            return error.userInfo[LYRExistingDistinctConversationKey] as! LYRConversation
        }
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

extension LayerService : LYRQueryControllerDelegate {
    public func queryControllerDidChangeContent(queryController: LYRQueryController!) {
        unreadCount.value = queryController.count()
    }
}