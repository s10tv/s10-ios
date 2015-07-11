//
//  ConversationInteractor.swift
//  S10
//
//  Created by Tony Xiao on 6/21/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Bond
import RealmSwift

public class ConversationInteractor {
    private let nc = NSNotificationCenter.defaultCenter().proxy()
    public let connection: Dynamic<Connection?>
    public let recipient: User
    public let formattedStatus: Dynamic<String>
    public let badgeText: Dynamic<String>
    public let messageViewModels: DynamicArray<MessageViewModel>
    public let busy: Dynamic<Bool>
    let downloading: Dynamic<Bool>
    let uploading: Dynamic<Bool>
    var disposable: Disposable!
    
    public init(recipient: User) {
        self.recipient = recipient
        connection = recipient.dynConnection
        messageViewModels = DynamicArray([])

        downloading = PropertyOf(false) {
            VideoDownloadTaskEntry.countOfDownloads(recipient.documentID!)
                |> map { $0 > 0 }
        }.dyn
        uploading = PropertyOf(false) {
            VideoUploadTaskEntry.countOfUploads(recipient.documentID!)
                |> map { $0 > 0 }
        }.dyn
        busy = reduce(uploading, downloading) { $0 || $1 }
        
        // TODO: Figure out how to make formattedStatus & badgeText also work when connection gets created
        if let connection = recipient.connection {
            formattedStatus = ConversationInteractor.formatStatus(connection, uploading: uploading, downloading: downloading)
            badgeText = reduce(connection.dynUnreadCount, busy) {
                ($0 != nil && $0! > 0 && $1 == false) ? "\($0!)" : ""
            }
        } else {
            formattedStatus = Dynamic("")
            badgeText = Dynamic("")
        }
        // TODO: Be much more fine-grained
        nc.listen(NSManagedObjectContextObjectsDidChangeNotification) { [weak self] note in
            self?.reloadMessages()
        }
        disposable = Realm().notifier().start(next: { [weak self] _ in
            self?.reloadMessages()
        })
    }
    
    public func reloadMessages() {
        let messages = Message
            .by(NSPredicate(format: "%K == %@ && %K != nil",
                MessageKeys.sender.rawValue, recipient,
                MessageKeys.video.rawValue))
            .sorted(by: MessageKeys.createdAt.rawValue, ascending: true)
            .fetch().map { $0 as! Message }
        
        var playableMessages: [MessageViewModel] = []
        for message in messages {
            if let videoId = message.video?.documentID,
                let localURL = VideoCache.sharedInstance.getVideo(videoId) {
                playableMessages.append(MessageViewModel(message: message, videoURL: localURL))
            }
        }
        if messageViewModels.value != playableMessages {
            messageViewModels.setArray(playableMessages)
        }
    }
    
    deinit {
        disposable.dispose()
    }
    
    class func formatStatus(connection: Connection, uploading: Dynamic<Bool>, downloading: Dynamic<Bool>) -> Dynamic<String> {
        let formattedAction: Dynamic<String?> = reduce(connection.dynLastMessageStatus, connection.dynOtherUser, connection.dynLastSender) {
            if let status = $0, let otherUser = $1, let lastSender = $2 {
                let receivedLast = (otherUser == lastSender)
                switch status {
                case .Sent: return receivedLast ? "Received" : "Sent"
                case .Opened: return receivedLast ? "Received" : "Opened"
                case .Expired: return receivedLast ? "Received" : "Opened"
                default: break
                }
            }
            return nil
        }
        let formattedDate: Dynamic<String?> = reduce(connection.dynUpdatedAt, CurrentDate) {
            Formatters.formatRelativeDate($0, relativeTo: $1)
        }
        let serverStatus = reduce(formattedAction, formattedDate) { (action: String?, date: String?) -> String in
            if let action = action, let date = date {
                return "\(action) \(date)"
            }
            return ""
        }
        return reduce(serverStatus, uploading, downloading) {
            if $1 { return "Sending..." }
            if $2 { return "Receiving..." }
            return $0
        }
    }
}
