//
//  ConversationViewModel.swift
//  S10
//
//  Created by Tony Xiao on 7/25/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Bond
import RealmSwift

func messageLoader(sender: User?) -> () -> [MessageViewModel] {
    return {
        // TODO: Move this off the main thread
        assert(NSThread.isMainThread(), "Must be performed on main for now")
        let query = sender.map {
            Message.by(MessageKeys.sender.rawValue, value: $0)
            } ?? Message.all()
        
        let messages = query
            // MASSIVE HACK ALERT: Ascending should be true but empirically
            // ascending = false seems to actually give us the correct result. FML.
            .sorted(by: MessageKeys.createdAt.rawValue, ascending: false)
            .fetch().map { $0 as! Message }
        
        var playableMessages: [MessageViewModel] = []
        for message in messages {
            if let localURL = VideoCache.sharedInstance.getVideo(message.documentID!) {
                playableMessages.append(MessageViewModel(message: message, localVideoURL: localURL))
            }
        }
        return playableMessages
    }
}

// Class or struct?
public class ConversationViewModel {

    let meteor: MeteorService
    let _messages: MutableProperty<[MessageViewModel]>
    let recipient: User?
    let currentUser: PropertyOf<User?>
    var openedMessages = Set<Message>()
    
    public let avatar: PropertyOf<Image?>
    public let displayName: PropertyOf<String>
    public let displayStatus: PropertyOf<String>
    public let busy: PropertyOf<Bool>
    public let messages: PropertyOf<[MessageViewModel]>
    public let exitAtEnd: Bool
    
    public let currentMessage: MutableProperty<MessageViewModel?>

    init(meteor: MeteorService, recipient: User?) {
        self.meteor = meteor
        self.recipient = recipient
        let loadMessages = messageLoader(recipient)

        currentMessage = MutableProperty(nil)
        currentUser = currentMessage
            |> map { $0?.message.sender ?? recipient }
        avatar = currentUser
            |> flatMap { $0.pAvatar() }
        displayName = currentUser
            |> flatMap(nilValue: "") { $0.pDisplayName() }
        busy = currentUser
            |> flatMap(nilValue: false) { $0.pConversationBusy() }
        displayStatus = currentMessage
            |> flatMap { $0?.formattedDate ?? recipient?.pConversationStatus() ?? PropertyOf("") }
        _messages = MutableProperty(loadMessages())
        messages = PropertyOf(_messages)
        exitAtEnd = recipient == nil
        
        // NOTE: ManagedObjectContext changes are ignored
        // So if video is removed nothing will happen
        _messages <~ Realm().notifier() |> map { _ in loadMessages() } |> skipRepeats { $0 == $1 }
    }
    
    public func openMessage(message: MessageViewModel) {
        openedMessages.insert(message.message)
    }
    
    public func expireOpenedMessages() {
        for message in openedMessages {
            VideoCache.sharedInstance.removeVideo(message.documentID!)
        }
        meteor.expireMessages(Array(openedMessages))
        openedMessages.removeAll()
    }
    
    public func profileVM() -> ProfileViewModel {
        return ProfileViewModel(meteor: meteor, user: currentUser.value!)
    }
}