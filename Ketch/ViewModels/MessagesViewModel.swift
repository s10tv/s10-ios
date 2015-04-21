//
//  MessagesViewModel.swift
//  Ketch
//
//  Created by Tony Xiao on 4/21/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import CoreData
import JSQMessagesViewController
import SDWebImage

// MARK: - MessagesViewModel

protocol MessagesViewModelDelegate : class {
    func viewModel(viewModel: MessagesViewModel, didChangeMessages messages: [Message])
}

class MessagesViewModel : NSObject {
    let connection: Connection
    weak var delegate: MessagesViewModelDelegate?
    private let frc: NSFetchedResultsController
    private var sendingMessage = false // TODO: Temp hack, see sendMessage for explanation
    private var changedMessages: [Message] = []
    
    var sender: User { return User.currentUser()! }
    var recipient: User { return connection.user! }
    
    init(connection: Connection, delegate: MessagesViewModelDelegate? = nil) {
        self.connection = connection
        self.delegate = delegate
        frc = connection.fetchMessages(sorted: true)
        super.init()
        frc.delegate = self
    }
    
    func loadMessages() {
        var error: NSError?
        if !frc.performFetch(&error) {
            Log.error("Unable to fetch messages", error)
        }
    }
    
    func markAsRead() {
        if connection.hasUnreadMessage == true {
            Meteor.markAsRead(connection)
        }
    }
    
    func sendMessage(text: String) {
        // meteor.sendMessage should return stub and allow us to more precisely keep track
        // of exactly which messages were sent by current client, instead of relying on
        // entire method call being finished
        sendingMessage = true
        Log.verbose("sendingMessage = true")
        Meteor.sendMessage(connection, text: text).deliverOnMainThread().subscribeErrorOrCompleted { _ in
            self.sendingMessage = false
            Log.verbose("sendingMessage = false")
        }
    }
    
    // MARK: -
    
    func numberOfMessages() -> Int {
        return frc.fetchedObjects?.count ?? 0
    }
    
    func messageAtIndex(index: Int) -> Message {
        return frc.fetchedObjects?[index] as Message
    }
    
    // TODO: Should this return raw string? And let viewLayer make it attributed?
    func displayTimestampForMessageAtIndex(index: Int) -> NSAttributedString? {
        if index % 3 == 0 {
            let text = Formatters.time.attributedTimestampForDate(messageAtIndex(index).createdAt)
            return text.replace(font: UIFont(.transatTextBold, size: 10), color: StyleKit.teal)
        }
        return nil
    }
    
    func displayReadDateForMessageAtIndex(index: Int) -> NSAttributedString? {
        if messageAtIndex(index) == connection.otherUserLastSeenMessage {
            let text = Formatters.formatRelativeDate(connection.otherUserLastSeenAt!)
            let range = NSMakeRange(0, text.length)
            var paragraphStlye = NSMutableParagraphStyle()
            paragraphStlye.alignment = .Right
            
            let str = NSMutableAttributedString(string: text)
            str.addAttribute(NSParagraphStyleAttributeName, value: paragraphStlye, range: range)
            str.addAttribute(NSFontAttributeName, value: UIFont(.transatTextStandard, size: 10), range: range)
            str.addAttribute(NSForegroundColorAttributeName, value: StyleKit.teal, range: range)
            
            return str
        }
        return nil
    }
    
    func promptText() -> String? {
        return connection.promptText
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension MessagesViewModel : NSFetchedResultsControllerDelegate {
    
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        changedMessages = []
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        Log.verbose("controller:didChangeObject \(anObject) changeType: \(type.rawValue)")
        if !sendingMessage {
            changedMessages.append(anObject as Message)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        // Can we be more specific about the changes
        if changedMessages.count > 0 {
            delegate?.viewModel(self, didChangeMessages: changedMessages)
        }
    }
}

// MARK: - ViewModel Extensions

extension Message {
    func jsqMessage() -> JSQMessage {
        let senderID = sender?.documentID
        let displayName = sender?.displayName
        let txt = text ?? "empty"
        return JSQMessage(senderId: senderID, senderDisplayName: displayName, date: createdAt, text: txt)
    }
}

extension User {
    func jsqAvatar() -> JSQMessagesAvatarImage {
        // TODO: Add gender to user
        let image = JSQMessagesAvatarImage(placeholder: UIImage(R.KetchAssets.girlPlaceholder))
        let key = SDWebImageManager.sharedManager().cacheKeyForURL(self.profilePhotoURL)
        image.avatarImage = SDImageCache.sharedImageCache().imageFromDiskCacheForKey(key)
        return image
    }
}