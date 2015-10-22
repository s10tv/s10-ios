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
    let unreadQueryController: LYRQueryController?
    public let layerClient: LYRClient
    
    public init(layerAppID: NSURL, meteor: MeteorService, existingClient: LYRClient? = nil) {
        self.meteor = meteor
        layerClient = LayerService.defaultLayerClient(layerAppID)
        let query = LYRQuery(queryableClass: LYRConversation.self)
        query.predicate = LYRPredicate(property: "hasUnreadMessages", predicateOperator: .IsEqualTo, value: true)
        unreadQueryController = try? layerClient.queryControllerWithQuery(query, error: ())
        super.init()
        layerClient.delegate = self
        unreadQueryController?.delegate = self
        _ = try? unreadQueryController?.execute()
        unreadCount.value = UInt(unreadQueryController?.count() ?? 0)
    }
    
    // MARK: -
    
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
            // BIG TODO: This is gonna crash if we are offline... Store currentUser info offline in UserDefaults
            var metadata = Participant(user: meteor.user.value!).asDictionary()
            for (k, v) in Participant(user: user).asDictionary() {
                metadata[k] = v // Better dic merge wanted
            }
            Log.info("Creating new conversation with metadata \(metadata)")
            return try layerClient.newConversationWithParticipants(Set([user.documentID!]), options: [
                LYRConversationOptionsDistinctByParticipantsKey: true,
                LYRConversationOptionsMetadataKey: metadata
            ])
        } catch let error as NSError {
            return error.userInfo[LYRExistingDistinctConversationKey] as! LYRConversation
        }
    }
    
    func findMessage(messageId: String) -> LYRMessage? {
        do {
            let query = LYRQuery(queryableClass: LYRMessage.self)
            query.predicate = LYRPredicate(property: "identifier", predicateOperator: .IsEqualTo, value: NSURL(messageId))
            return try layerClient.executeQuery(query).firstObject as? LYRMessage
        } catch let error as NSError {
            Log.error("Unable to find message with id \(messageId)", error)
        }
        return nil
    }
    
    func unreadTextMessagesQuery(conversation: LYRConversation) -> LYRQuery {
        let query = LYRQuery(queryableClass: LYRMessage.self)
        query.predicate = LYRCompoundPredicate(type: .And, subpredicates: [
            LYRPredicate(property: "parts.MIMEType", predicateOperator: .IsNotEqualTo, value: kMIMETypeVideo),
            LYRPredicate(property: "conversation", predicateOperator: .IsEqualTo, value: conversation),
            LYRPredicate(property: "isUnread", predicateOperator: .IsEqualTo, value: true),
        ])
        return query
    }
    
    func unplayedVideoMessages(conversation: LYRConversation) -> [LYRMessage] {
        let query = LYRQuery(queryableClass: LYRMessage.self)
        query.predicate = LYRCompoundPredicate(type: .And, subpredicates: [
            LYRPredicate(property: "parts.MIMEType", predicateOperator: .IsEqualTo, value: kMIMETypeVideo),
            LYRPredicate(property: "parts.transferStatus", predicateOperator: .IsEqualTo, value: LYRContentTransferStatus.Complete.rawValue),
            LYRPredicate(property: "conversation", predicateOperator: .IsEqualTo, value: conversation),
            LYRPredicate(property: "isUnread", predicateOperator: .IsEqualTo, value: true),
        ])
        do {
            return try layerClient.executeQuery(query).map { $0 as! LYRMessage }
        } catch let error as NSError {
            Log.error("Unable to find video messages", error)
            return []
        }
    }
    
    func countOfUploads(conversation: LYRConversation? = nil) -> PropertyOf<UInt> {
        return PropertyOf(initialValue: countUploads(conversation), producer: layerClient.objectChanges().map { _ in
            return self.countUploads(conversation)
        })
    }
    
    func countOfDownloads(conversation: LYRConversation? = nil) -> PropertyOf<UInt> {
        return PropertyOf(initialValue: countDownloads(conversation), producer: layerClient.objectChanges().map { _ in
            return self.countDownloads(conversation)
        })
    }
    
    private func countUploads(conversation: LYRConversation? = nil) -> UInt {
        do {
            return try layerClient.countForQuery(LYRQuery.uploadingMessages(conversation))
        } catch let error as NSError {
            Log.error("Unable to count uploads messages", error)
        }
        return 0
    }

    
    private func countDownloads(conversation: LYRConversation? = nil) -> UInt {
        do {
            return try layerClient.countForQuery(LYRQuery.downloadingMessages(conversation))
        } catch let error as NSError {
            Log.error("Unable to count downloads messages", error)
        }
        return 0
    }
    
    func lastMessageOf(conversation: LYRConversation) -> PropertyOf<LYRMessage?> {
        return PropertyOf(initialValue: conversation.lastMessage, producer: layerClient.objectChanges()
            .flatMap(.Merge) { changes in
                for change in changes {
                    if let c = change.object as? LYRConversation, let p = change.property
                        where c == conversation && p == "lastMessage" {
                        return SignalProducer(value: conversation.lastMessage)
                    }
                    if let m = change.object as? LYRMessage where m == conversation.lastMessage {
                        return SignalProducer(value: m)
                    }
                }
                return .empty
            })
    }
    
    // MARK: - Authentication
    
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
    
    // MARK: -
    
    public static func defaultLayerClient(layerAppID: NSURL) -> LYRClient {
        let layerClient = LYRClient(appID: layerAppID)
        layerClient.autodownloadMaximumContentSize = 50 * 1024 * 1024 // 50mb
        layerClient.backgroundContentTransferEnabled = true
        layerClient.diskCapacity = 300 * 1024 * 1024 // 300mb
        layerClient.autodownloadMIMETypes = nil // Download all automatically
        return layerClient
    }
}

extension LayerService : LYRQueryControllerDelegate {
    public func queryControllerDidChangeContent(queryController: LYRQueryController!) {
        unreadCount.value = queryController.count()
    }
}

extension LayerService : LYRClientDelegate {
    public func layerClient(client: LYRClient!, didReceiveAuthenticationChallengeWithNonce nonce: String!) {
        meteor.layerAuth(nonce).producer.flatMap(.Concat) { identityToken in
            self.layerClient.authenticate(identityToken)
        }.start(Event.sink(error: { error in
            Log.error("Unable to update user in Layer session", error)
        }, next: { userId in
            Log.info("Updated user in Layer session userId=\(userId)")
        }))
    }
    
    public func layerClient(client: LYRClient!, objectsDidChange changes: [AnyObject]!) {
        Log.debug("Layer objects did change \(changes)")
    }
    
    public func layerClient(client: LYRClient!, willBeginContentTransfer contentTransferType: LYRContentTransferType, ofObject object: AnyObject!, withProgress progress: LYRProgress!) {
        Log.debug("Will begin \(contentTransferType) \(object)")
    }
    
    public func layerClient(client: LYRClient!, didFinishContentTransfer contentTransferType: LYRContentTransferType, ofObject object: AnyObject!) {
        Log.debug("did finish \(contentTransferType) \(object)")
    }
    
    public func layerClient(client: LYRClient!, didFailOperationWithError error: NSError!) {
        Log.error("Layer failed to perform operation", error)
    }
}