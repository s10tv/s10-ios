//
//  MessagesViewModel.swift
//  Ketch
//
//  Created by Tony Xiao on 4/21/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import CoreData
import SDWebImage

// MARK: - MessagesViewModel

protocol MessagesViewModelDelegate : class {
    func viewModel(viewModel: MessagesViewModel, didChangeMessages messages: [Message])
}

class MessagesViewModel : NSObject {
    let conversation: Conversation
    weak var delegate: MessagesViewModelDelegate?
    private let frc: NSFetchedResultsController
    private var sendingMessage = false // TODO: Temp hack, see sendMessage for explanation
    private var changedMessages: [Message] = []
    
    var sender: User { return User.currentUser()! }
    var recipient: User { return conversation.otherUser! }
    
    init(conversation: Conversation, delegate: MessagesViewModelDelegate? = nil) {
        self.conversation = conversation
        self.delegate = delegate
        frc = conversation.fetchMessages(sorted: true)
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
    }
    
    func sendMessage(text: String) {
    }
    
    // MARK: -
    
    func numberOfMessages() -> Int {
        return frc.fetchedObjects?.count ?? 0
    }
    
    func messageAtIndex(index: Int) -> Message {
        return frc.fetchedObjects?[index] as! Message
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
            changedMessages.append(anObject as! Message)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        // Can we be more specific about the changes
        if changedMessages.count > 0 {
            delegate?.viewModel(self, didChangeMessages: changedMessages)
        }
    }
}