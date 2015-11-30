//
//  LayerQueries.swift
//  Taylr
//
//  Created by Tony Xiao on 11/18/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import LayerKit

extension LYRQuery {
    static func unreadConversations() -> LYRQuery {
        let query = LYRQuery(queryableClass: LYRConversation.self)
        query.predicate = LYRPredicate(property: "hasUnreadMessages", predicateOperator: .IsEqualTo, value: true)
        return query
    }
    
    static func transferingMessages(conversation: LYRConversation? = nil) -> LYRQuery {
        let query = LYRQuery(queryableClass: LYRMessage.self)
        let statuses: [LYRContentTransferStatus] = [.AwaitingUpload, .Uploading, .Downloading]
        var predicates = [
            LYRPredicate(property: "parts.MIMEType", predicateOperator: .IsEqualTo, value: kMIMETypeVideo),
            LYRPredicate(property: "parts.transferStatus", predicateOperator: .IsIn, value: statuses.map { $0.rawValue }),
        ]
        if let conversation = conversation {
            predicates.append(LYRPredicate(property: "conversation", predicateOperator: .IsEqualTo, value: conversation))
        }
        query.predicate = LYRCompoundPredicate(type: .And, subpredicates: predicates)
        return query
    }
    
    static func uploadingMessages(conversation: LYRConversation? = nil) -> LYRQuery {
        let query = LYRQuery(queryableClass: LYRMessage.self)
        let statuses = [LYRContentTransferStatus.AwaitingUpload.rawValue, LYRContentTransferStatus.Uploading.rawValue]
        var predicates = [
            LYRPredicate(property: "parts.MIMEType", predicateOperator: .IsEqualTo, value: kMIMETypeVideo),
            LYRPredicate(property: "parts.transferStatus", predicateOperator: .IsIn, value: statuses),
            //            LYRPredicate(property: "sender.userID", predicateOperator: .IsEqualTo, value: userId),
        ]
        if let conversation = conversation {
            predicates.append(LYRPredicate(property: "conversation", predicateOperator: .IsEqualTo, value: conversation))
        }
        query.predicate = LYRCompoundPredicate(type: .And, subpredicates: predicates)
        return query
    }
    
    static func downloadingMessages(conversation: LYRConversation? = nil) -> LYRQuery {
        let query = LYRQuery(queryableClass: LYRMessage.self)
        let statuses = [LYRContentTransferStatus.Downloading.rawValue] // Do not include ReadyToDownload for now
        var predicates = [
            LYRPredicate(property: "parts.MIMEType", predicateOperator: .IsEqualTo, value: kMIMETypeVideo),
            LYRPredicate(property: "parts.transferStatus", predicateOperator: .IsIn, value: statuses),
            // TODO: Technically we should not restrict by this, but in practice a non-trivial # of thumbnails get stuck in downloading state
            // Maybe we should figure out some other work around?
            LYRPredicate(property: "isUnread", predicateOperator: .IsEqualTo, value: true),
//            LYRPredicate(property: "sender.userID", predicateOperator: .IsNotEqualTo, value: userId),
        ]
        if let conversation = conversation {
            predicates.append(LYRPredicate(property: "conversation", predicateOperator: .IsEqualTo, value: conversation))
        }
        query.predicate = LYRCompoundPredicate(type: .And, subpredicates: predicates)
        return query
    }
}
