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
    public let busy: PropertyOf<Bool>
    let downloading: Dynamic<Bool>
    let uploading: Dynamic<Bool>
    var disposable: Disposable!
    
    public enum State {
        case Idle, Playing, Recording
    }
    public let playing: MutableProperty<Bool>
    public let recording: MutableProperty<Bool>
    public let state: PropertyOf<State>
    
    // TODO: Turns out interactor is being repeatedly created so many times. 
    // At the minimum there should not be side effects when creating interactor. 
    // e.g. signal producer and such should only be started on demand. Make variables lazy
    // and do not hook up listeners till ready
    public init(recipient: User) {
        self.recipient = recipient
        connection = recipient.dynConnection
        messageViewModels = DynamicArray([])
        
        let playing = MutableProperty(false)
        let recording = MutableProperty(false)
        self.playing = playing
        self.recording = recording
        state = PropertyOf(.Idle) {
            return combineLatest(
                playing.producer,
                recording.producer
            ) |> map { playing, recording -> State in
                if !playing && !recording { return .Idle }
                if playing { return .Playing }
                if recording { return .Recording }
                return .Idle
            } |> skipRepeats // TODO: There really shouldn't be repeats much
        }


        downloading = toBondDynamic(PropertyOf(false) {
            VideoDownloadTaskEntry.countOfDownloads(recipient.documentID!)
                |> map { $0 > 0 }
        })
        uploading = toBondDynamic(PropertyOf(false) {
            VideoUploadTaskEntry.countOfUploads(recipient.documentID!)
                |> map { $0 > 0 }
        })
        busy = PropertyOf(false) {
            combineLatest(
                VideoUploadTaskEntry.countOfUploads(recipient.documentID!),
                VideoDownloadTaskEntry.countOfDownloads(recipient.documentID!)
            ) |> map { uploads, downloads in
                uploads > 0 || downloads > 0
            }
        }

        
        // TODO: Figure out how to make formattedStatus & badgeText also work when connection gets created
        if let connection = recipient.connection {
            formattedStatus = ConversationInteractor.formatStatus(connection, uploading: uploading, downloading: downloading)
            badgeText = reduce(connection.dynUnreadCount, toBondDynamic(busy)) {
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
            // MASSIVE HACK ALERT: Ascending should be true but empirically
            // ascending = false seems to actually give us the correct result. FML.
            .sorted(by: MessageKeys.createdAt.rawValue, ascending: false)
            .fetch().map { $0 as! Message }
        
        var playableMessages: [MessageViewModel] = []
//        var earlierDate: NSDate?
        for message in messages {
//            if let earlierDate = earlierDate {
//                assert(earlierDate < message.createdAt!)
//            }
//            earlierDate = message.createdAt
            if let videoId = message.video?.documentID,
                let localURL = VideoCache.sharedInstance.getVideo(videoId) {
                playableMessages.append(MessageViewModel(message: message, videoURL: localURL))
            }
        }
        if messageViewModels.value != playableMessages {
//            println("interactor: \(unsafeAddressOf(self))")
//            println("messageViewModels addr: \(unsafeAddressOf(messageViewModels))")
//            dump(messageViewModels.value.map { "\($0) \($0.message.createdAt)" }, name: "oldValue", maxDepth: 1)
//            dump(playableMessages.map { "\($0) \($0.message.createdAt)" }, name: "newValue", maxDepth: 1)
            messageViewModels.setArray(playableMessages)
        }
    }
    
    deinit {
//        println("Interactor dispose")
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
