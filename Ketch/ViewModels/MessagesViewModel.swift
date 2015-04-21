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

class MessagesViewModel : NSObject {
    let connection: Connection
    private let frc: NSFetchedResultsController
    
    var sender: User { return User.currentUser()! }
    var recipient: User { return connection.user! }
    
    init(connection: Connection) {
        self.connection = connection
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
        Meteor.sendMessage(connection, text: text)
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
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
    }
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
    }
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        println("Content changed")
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