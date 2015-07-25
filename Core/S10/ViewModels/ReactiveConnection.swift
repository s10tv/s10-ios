//
//  ReactiveConnection.swift
//  S10
//
//  Created by Tony Xiao on 7/25/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

extension Connection {
    func dyn(keyPath: ConnectionKeys) -> DynamicProperty {
        return dyn(keyPath.rawValue)
    }
    
    func serverStatus() -> String {
        if let status = lastMessageStatus {
            let receivedLast = (otherUser == lastSender)
            let formattedDate = Formatters.formatRelativeDate(updatedAt)
            let action: String = {
                switch status {
                case .Sent: return receivedLast ? "Received" : "Sent"
                case .Opened: return receivedLast ? "Received" : "Opened"
                case .Expired: return receivedLast ? "Received" : "Opened"
                }
                }()
            return "\(action) \(formattedDate)"
        }
        return ""
    }
    
    func pBusy() -> PropertyOf<Bool> {
        return PropertyOf(false, combineLatest(
            VideoUploadTask.countOfUploads(otherUser.documentID!),
            VideoDownloadTask.countOfDownloads(otherUser.documentID!)
        ) |> map { uploads, downloads in
            uploads > 0 || downloads > 0
        })
    }
    
    func pStatusMessage() -> PropertyOf<String> {
        return PropertyOf("", combineLatest(
            VideoUploadTask.countOfUploads(otherUser.documentID!),
            VideoDownloadTask.countOfDownloads(otherUser.documentID!),
            timer(1, onScheduler: QueueScheduler.mainQueueScheduler)
                |> map { [weak self] _ in self?.serverStatus() }
        ) |> map {
            if $0 > 0 { return "Sending..." }
            if $1 > 0 { return "Receiving..." }
            return $2 ?? ""
        })
    }
}
