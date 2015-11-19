//
//  LayerService.swift
//  S10
//
//  Created by Tony Xiao on 10/14/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import CocoaLumberjack
import ReactiveCocoa
import LayerKit
import React

@objc(TSLayerService)
class LayerService: NSObject {
    @objc weak var bridge: RCTBridge?
    
    let layerClient: LYRClient
    let unreadQueryController: LYRQueryController?
    var currentUser: UserViewModel?
    
    init(layerAppID: NSURL) {
        layerClient = LYRClient(appID: layerAppID)
        layerClient.autodownloadMaximumContentSize = 50 * 1024 * 1024 // 50mb
        layerClient.backgroundContentTransferEnabled = true
        layerClient.diskCapacity = 300 * 1024 * 1024 // 300mb
        layerClient.autodownloadMIMETypes = nil // Download all automatically
        unreadQueryController = try? layerClient.queryControllerWithQuery(LYRQuery.unreadConversations(), error: ())
        super.init()
        layerClient.delegate = self
        unreadQueryController?.delegate = self
        _ = try? unreadQueryController?.execute()
        queryControllerDidChangeContent(unreadQueryController) // Force trigger
    }
    
    // MARK: -
    
    func findConversation(conversationId: String) -> LYRConversation? {
        let query = LYRQuery(queryableClass: LYRConversation.self)
        query.predicate = LYRPredicate(property: "identifier", predicateOperator: .IsEqualTo, value: conversationId)
        query.limit = 1
        return (try? layerClient.executeQuery(query).firstObject) as? LYRConversation
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
    
    func getOrCreateConversation(user: UserViewModel) throws -> LYRConversation {
        do {
            // BIG TODO: Make sure we store currentUser info offline in UserDefaults
            guard let currentUser = currentUser else {
                throw NSError(domain: "Layer", code: 0, userInfo: [
                    NSLocalizedFailureReasonErrorKey: "Cannot get conversation when currentUser is nil"
                ])
            }
            var metadata = currentUser.asDictionary()
            for (k, v) in user.asDictionary() {
                metadata[k] = v // Better dic merge wanted
            }
            DDLogInfo("Creating new conversation with metadata \(metadata)")
            return try layerClient.newConversationWithParticipants(Set([user.userId]), options: [
                LYRConversationOptionsDistinctByParticipantsKey: true,
                LYRConversationOptionsMetadataKey: metadata
            ])
        } catch let error as NSError {
            if let c = error.userInfo[LYRExistingDistinctConversationKey] as? LYRConversation {
                return c
            }
            throw error
        }
    }
    
    func findMessage(messageId: String) -> LYRMessage? {
        do {
            let query = LYRQuery(queryableClass: LYRMessage.self)
            query.predicate = LYRPredicate(property: "identifier", predicateOperator: .IsEqualTo, value: NSURL(messageId))
            return try layerClient.executeQuery(query).firstObject as? LYRMessage
        } catch let error as NSError {
            DDLogError("Unable to find message with id \(messageId) \(error)")
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
            DDLogError("Unable to find video messages \(error)")
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
            DDLogError("Unable to count uploads messages \(error)")
        }
        return 0
    }
    
    private func countDownloads(conversation: LYRConversation? = nil) -> UInt {
        do {
            return try layerClient.countForQuery(LYRQuery.downloadingMessages(conversation))
        } catch let error as NSError {
            DDLogError("Unable to count downloads messages \(error)")
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
}

// MARK: - LYRClientDelegate

extension LayerService : LYRClientDelegate {
    
    func layerClient(client: LYRClient!, objectsDidChange changes: [AnyObject]!) {
        DDLogDebug("Layer objects did change \(changes)")
    }
    
    func layerClient(client: LYRClient!, willBeginContentTransfer contentTransferType: LYRContentTransferType, ofObject object: AnyObject!, withProgress progress: LYRProgress!) {
        DDLogDebug("Will begin \(contentTransferType) \(object)")
    }
    
    func layerClient(client: LYRClient!, didFinishContentTransfer contentTransferType: LYRContentTransferType, ofObject object: AnyObject!) {
        DDLogDebug("did finish \(contentTransferType) \(object)")
    }
    
    func layerClient(client: LYRClient!, didFailOperationWithError error: NSError!) {
        DDLogError("Layer failed to perform operation \(error)")
    }

    func layerClient(client: LYRClient!, didReceiveAuthenticationChallengeWithNonce nonce: String!) {
        assert(bridge != nil, "Bridge should not be nil")
        bridge?.eventDispatcher.sendAppEventWithName("Layer.didReceiveNonce", body: nonce)
        // Expect JavaScript side to then call LayerService.authenticate to proceed
    }
}

// MARK: - LYRQueryControllerDelegate

extension LayerService : LYRQueryControllerDelegate {
    func queryControllerDidChangeContent(queryController: LYRQueryController!) {
        bridge?.eventDispatcher.sendAppEventWithName("Layer.unreadCountUpdate", body: queryController.count())
    }
}

// MARK: - NativeModule API

extension LayerService {
    
    @objc func requestAuthenticationNonce() {
        layerClient.requestAuthenticationNonce().start(Event.sink(error: { error in
            DDLogError("Unable to get authentication nonce \(error)")
        }, next: { nonce in
            DDLogInfo("Did receive authentication nonce \(nonce)")
        }))
    }
    
    @objc func authenticate(identityToken: String) {
        layerClient.authenticate(identityToken).start(Event.sink(error: { error in
            DDLogError("Unable to update user in Layer session \(error)")
        }, next: { userId in
            DDLogInfo("Updated user in Layer session userId=\(userId)")
        }))
    }
    
    @objc func deauthenticate() {
        layerClient.deauthenticate().start(Event.sink(error: { error in
            DDLogError("Unable to deauthenticate \(error)")
        }, completed: {
            DDLogInfo("Successfully deauthenticated from layer")
        }))
    }
}
