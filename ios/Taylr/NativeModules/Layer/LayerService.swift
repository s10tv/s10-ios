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
    @objc weak var bridge: RCTBridge? {
        didSet {
            if layerClient.isAuthenticated { setupQueries() }
        }
    }
    
    let layerClient: LYRClient
    var unreadQueryController: LYRQueryController?
    var allConversationsQueryController: LYRQueryController?
    
    init(layerAppID: NSURL) {
        layerClient = LYRClient(appID: layerAppID)
        layerClient.autodownloadMaximumContentSize = 50 * 1024 * 1024 // 50mb
        layerClient.backgroundContentTransferEnabled = true
        layerClient.diskCapacity = 300 * 1024 * 1024 // 300mb
        layerClient.autodownloadMIMETypes = nil // Download all automatically
        super.init()
        layerClient.delegate = self
    }
    
    func setupQueries() {
        DDLogDebug("Will setup conversation queryies isConnected=\(layerClient.isConnected)")
        guard let bridge = bridge else {
            DDLogError("self.bridge must exist before calling setupQueries")
            return
        }
        do {
            unreadQueryController = try layerClient.queryControllerWithQuery(LYRQuery.unreadConversations(), error: ())
            if let query = unreadQueryController {
                query.delegate = self
                try query.execute()
                DDLogDebug("Will send initial unread converssations count=\(query.count())")
                bridge.sendAppEvent("Layer.unreadConversationsCountUpdate", body: query.count())
            }
            
            allConversationsQueryController = try layerClient.queryControllerWithQuery(
                LYRQuery(queryableClass: LYRConversation.self), error: ())
            if let query = allConversationsQueryController {
                query.delegate = self
                try query.execute()
                DDLogDebug("Will send initial all converssations count=\(query.count())")
                bridge.sendAppEvent("Layer.allConversationsCountUpdate", body: query.count())
            }
        } catch let error as NSError {
            DDLogError("Unable to setup queries", tag: error)
        }
    }
    
    func teardownQueries() {
        unreadQueryController = nil
        allConversationsQueryController = nil
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
    
    func getOrCreateConversation(users: [UserViewModel]) throws -> LYRConversation {
        do {
            var metadata: [String: String] = [:]
            for user in users {
                for (k, v) in user.asDictionary() {
                    metadata[k] = v // Better dic merge wanted
                }
            }
            let ids = Set(users.map { $0.userId })
            let options: [NSObject: AnyObject] = [
                LYRConversationOptionsDistinctByParticipantsKey: true,
                LYRConversationOptionsMetadataKey: metadata
            ]

            DDLogInfo("Creating new conversation with metadata \(metadata)")
            do {
                return try layerClient.newConversationWithParticipants(ids, options: options)
            } catch let error as NSError {
                // Small hack, see http://stackoverflow.com/q/33975928/692499
                if error.domain == "FMDatabase" && error.code == 0 {
                    DDLogWarn("Got false positive FMDB error, will attempt refetch error=\(error)")
                    return try layerClient.newConversationWithParticipants(ids, options: options)
                }
                throw error
            }
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
            DDLogError("Unable to find message messageId=\(messageId)", tag: error)
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
            DDLogError("Unable to find video messages", tag: error)
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
            DDLogError("Unable to count uploads messages", tag: error)
        }
        return 0
    }
    
    private func countDownloads(conversation: LYRConversation? = nil) -> UInt {
        do {
            return try layerClient.countForQuery(LYRQuery.downloadingMessages(conversation))
        } catch let error as NSError {
            DDLogError("Unable to count downloads messages", tag: error)
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
        DDLogVerbose("Layer objects did change \(changes)")
    }
    
    func layerClient(client: LYRClient!, willBeginContentTransfer contentTransferType: LYRContentTransferType, ofObject object: AnyObject!, withProgress progress: LYRProgress!) {
        DDLogVerbose("Will begin \(contentTransferType) \(object)")
    }
    
    func layerClient(client: LYRClient!, didFinishContentTransfer contentTransferType: LYRContentTransferType, ofObject object: AnyObject!) {
        DDLogVerbose("did finish \(contentTransferType) \(object)")
    }
    
    func layerClient(client: LYRClient!, didFailOperationWithError error: NSError!) {
        DDLogError("Layer failed to perform operation", tag: error)
    }

    // TODO: Implement JavaScript get identity token then call LayerService.authenticate
    func layerClient(client: LYRClient!, didReceiveAuthenticationChallengeWithNonce nonce: String!) {
        assert(bridge != nil, "Bridge should not be nil")
        DDLogInfo("Received authentication nonce in delegate \(nonce)")
        bridge?.sendAppEvent("Layer.didReceiveNonce", body: nonce)
    }
}

// MARK: - NativeModule API

extension LayerService : LYRQueryControllerDelegate {
    func queryControllerDidChangeContent(queryController: LYRQueryController!) {
        if queryController == unreadQueryController {
            bridge?.sendAppEvent("Layer.unreadConversationsCountUpdate", body: queryController.count())
            DDLogDebug("Unread conversations did update count=\(queryController.count())")
        } else if queryController == allConversationsQueryController {
            bridge?.sendAppEvent("Layer.allConversationsCountUpdate", body: queryController.count())
            DDLogDebug("All conversations did update count=\(queryController.count())")
        }
    }
}

extension LayerService {
    
    @objc func connect(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        DDLogDebug("Will connect to layer")
        layerClient.connect().promise(resolve, reject).start(Event.sink(error: { error in
            DDLogError("Unable to connect to layer", tag: error)
        }, completed: {
            DDLogInfo("Successfully connected to Layer")
        }))
    }
    
    @objc func isAuthenticated(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        resolve(layerClient.isAuthenticated)
    }
    
    @objc func requestAuthenticationNonce(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        DDLogDebug("Will request authentication nonce")
        layerClient.requestAuthenticationNonce().promise(resolve, reject).start(Event.sink(error: { error in
            DDLogError("Unable to get authentication nonce", tag: error)
        }, next: { nonce in
            DDLogDebug("Did receive requested authentication nonce \(nonce)")
        }))
    }
    
    @objc func authenticate(identityToken: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        DDLogDebug("Will authenticate with layer \(identityToken)")
        layerClient.authenticate(identityToken).promise(resolve, reject).start(Event.sink(error: { error in
            DDLogError("Unable to update user in Layer session", tag: error)
        }, next: { userId in
            DDLogInfo("Updated user in Layer session userId=\(userId)")
            self.setupQueries()
        }))
    }
    
    @objc func deauthenticate(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        DDLogDebug("Will deauthenticate from layer")
        layerClient.deauthenticate().promise(resolve, reject).start(Event.sink(error: { error in
            self.teardownQueries()
            DDLogError("Unable to deauthenticate", tag: error)
        }, completed: {
            DDLogInfo("Successfully deauthenticated from layer")
        }))
    }
}
