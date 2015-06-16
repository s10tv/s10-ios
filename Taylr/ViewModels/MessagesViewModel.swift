//
//  MessagesViewModel.swift
//  Taylr
//
//  Created by Tony Xiao on 4/21/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import CoreData
import SDWebImage

// MARK: - MessagesViewModel

protocol MessagesViewModelDelegate : class {
    func viewModel(viewModel: MessagesViewModel, didChangeMessages messages: [Message])
}

class MessagesViewModel : NSObject {
    let connection: Connection
    weak var delegate: MessagesViewModelDelegate?
    weak var collectionView : UICollectionView?
    let frc: NSFetchedResultsController
    private var sendingMessage = false // TODO: Temp hack, see sendMessage for explanation
    private var changedMessages: [Message] = []
    
    var sender: User { return User.currentUser()! }
    var recipient: User { return connection.otherUser! }
    
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
    }
    
    func sendMessage(text: String) {
    }
    
    
    func bindCollectionView(collectionView: UICollectionView) {
        self.collectionView = collectionView
//        collectionView.dataSource = self
        collectionView.delegate = self
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
        collectionView?.reloadData()
    }
}



extension MessagesViewModel : UICollectionViewDelegate {
    
}