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

let kMIMETypeText = "text/plain"
let kMIMETypeLocation = "location/coordinate"
let kMIMETypeImage = "image/jpeg"
let kMIMETypeVideo = "video/mp4"
let kMIMETypeThumbnail = "image/jpeg+preview"
let kMIMETypeMetadata = "application/json+imageSize"

struct ContentTransferUpdate {
    enum Kind {
        case WillBegin(LYRProgress), DidFinish
    }
    let kind: Kind
    let type: LYRContentTransferType
    let object: AnyObject
    var progress: LYRProgress? {
        switch kind {
        case .WillBegin(let progress):
            return progress
        default:
            return nil
        }
    }
}

extension LYRRecipientStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Invalid: return "Not Sent"
        case .Pending: return "Pending"
        case .Sent: return "Sent"
        case .Delivered: return "Delivered"
        case .Read: return "Opened"
        }
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

extension LYRMessage {
    public var messageParts: [LYRMessagePart] {
        return parts.map { $0 as! LYRMessagePart }
    }
    public var textPart: LYRMessagePart? {
        return messageParts.filter { $0.MIMEType == kMIMETypeText }.first
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
    
    public func asString() -> String? {
        return (data as NSData?).flatMap { String(data: $0, encoding: NSUTF8StringEncoding) }
    }
    
    public func asImage() -> UIImage? {
        return (data as NSData?).flatMap { UIImage(data: $0) }
    }
    
    public func asJson() -> AnyObject? {
        return (data as NSData?).flatMap { try? NSJSONSerialization.JSONObjectWithData($0, options: []) }
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
    
    // MARK: Queries
    
    func countForQuery(query: LYRQuery) throws -> UInt {
        var error: NSError?
        let count = countForQuery(query, error: &error)
        if let error = error {
            throw error
        }
        return count
    }
    
    // MARK: Notifications
    
    func syncStarts() -> SignalProducer<NSNotification, NoError> {
        return NSNotificationCenter.defaultCenter()
            .rac_notifications(LYRClientWillBeginSynchronizationNotification, object: self)
    }
    
    func syncEnds() -> SignalProducer<NSNotification, NoError> {
        return NSNotificationCenter.defaultCenter()
            .rac_notifications(LYRClientDidFinishSynchronizationNotification, object: self)
    }
    
    func objectChanges() -> SignalProducer<[LYRObjectChange], NoError> {
        return NSNotificationCenter.defaultCenter()
            .rac_notifications(LYRClientObjectsDidChangeNotification, object: self)
            .map { note in
                if let changes = note.userInfo?[LYRClientObjectChangesUserInfoKey] as? [LYRObjectChange] {
                    return changes
                }
                return []
            }
    }
    
    func contentTransferStarts() -> SignalProducer<ContentTransferUpdate, NoError> {
        return NSNotificationCenter.defaultCenter()
            .rac_notifications(LYRClientWillBeginContentTransferNotification, object: self)
            .flatMap(.Merge) { note in
                if let rawType = note.userInfo?[LYRClientContentTransferTypeUserInfoKey] as? Int,
                    let type = LYRContentTransferType(rawValue: rawType),
                    let object = note.userInfo?[LYRClientContentTransferObjectUserInfoKey],
                    let progress = note.userInfo?[LYRClientContentTransferProgressUserInfoKey] as? LYRProgress {
                        let update = ContentTransferUpdate(kind: .WillBegin(progress), type: type, object: object)
                        return SignalProducer(value: update)
                }
                return .empty
            }
    }
    
    func contentTransferEnds() -> SignalProducer<ContentTransferUpdate, NoError> {
        return NSNotificationCenter.defaultCenter()
            .rac_notifications(LYRClientDidFinishContentTransferNotification, object: self)
            .flatMap(.Merge) { note in
                if let rawType = note.userInfo?[LYRClientContentTransferTypeUserInfoKey] as? Int,
                    let type = LYRContentTransferType(rawValue: rawType),
                    let object = note.userInfo?[LYRClientContentTransferObjectUserInfoKey] {
                        let update = ContentTransferUpdate(kind: .DidFinish, type: type, object: object)
                        return SignalProducer(value: update)
                }
                return .empty
        }
    }
}
