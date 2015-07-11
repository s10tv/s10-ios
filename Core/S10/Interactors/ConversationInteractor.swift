//
//  ConversationInteractor.swift
//  S10
//
//  Created by Tony Xiao on 6/21/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Bond
import RealmSwift

public class ConversationInteractor {
    private let nc = NSNotificationCenter.defaultCenter().proxy()
    private let realmToken: NotificationToken
    private var realmToken2: NotificationToken!
    private let downloadService: DownloadService
    public let connection: Dynamic<Connection?>
    public let recipient: User
    public let formattedStatus: Dynamic<String>
    public let badgeText: Dynamic<String>
    public let hasUnsentMessage: Dynamic<Bool>
    public let messageViewModels: DynamicArray<MessageViewModel>
    
    public init(recipient: User, downloadService: DownloadService) {
        self.recipient = recipient
        self.downloadService = downloadService
        connection = recipient.dynConnection
        (hasUnsentMessage, realmToken) = ConversationInteractor.observeUnsentMessage(recipient)
        messageViewModels = DynamicArray([])
        
        // TODO: Figure out how to make formattedStatus & badgeText also work when connection gets created
        if let connection = recipient.connection {
            formattedStatus = ConversationInteractor.formatStatus(connection)
            badgeText = reduce(connection.dynUnreadCount, hasUnsentMessage) {
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
        realmToken2 = Realm().addNotificationBlock { [weak self] _ in
            self?.reloadMessages()
        }
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
        Realm().removeNotification(realmToken)
        Realm().removeNotification(realmToken2)
    }
    
    class func observeUnsentMessage(recipient: User) -> (Dynamic<Bool>, NotificationToken) {
        let realm = Realm()
        let recipientId = recipient.documentID!
        let countUnsent = { (realm: Realm) in
            return realm.objects(VideoUploadTaskEntry).filter("recipientId = %@", recipientId).count
        }
        let hasUnsent = Dynamic(countUnsent(realm) > 0)
        let token = realm.addNotificationBlock { hasUnsent.value = countUnsent($1) > 0 }
        return (deliver(hasUnsent, on: dispatch_get_main_queue()), token)
    }
    
    class func formatStatus(connection: Connection) -> Dynamic<String> {
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
        return reduce(formattedAction, formattedDate) {
            if let action = $0, let date = $1 {
                return "\(action) \(date)"
            }
            return ""
        }
    }
}
