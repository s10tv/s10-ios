//
//  ConversationViewModel.swift
//  S10
//
//  Created by Tony Xiao on 6/21/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation

public class ConversationViewModel : NSObject {
    let frc: NSFetchedResultsController
    public private(set) var recipient: User
    public private(set) var messageVMs: [MessageViewModel] = []
    public var didReload: (([MessageViewModel]) -> ())?
    public var reloadNeeded = false
    
    public init(connection: Connection) {
        recipient = connection.otherUser!
        frc = connection.fetchMessages(sorted: true)
        super.init()
        frc.delegate = self
//        listenForNotification(NSManagedObjectContextObjectsDidChangeNotification).subscribeNext { (obj) -> Void in
//            println("Objects changing incontext")
//        }
    }
    
    public func reloadData() {
        messageVMs = frc.fetchObjects().map {
            MessageViewModel(message: $0 as! Message)
        }
        messageVMs.sort { $0.isOrderedBefore($1) }
        didReload?(messageVMs)
    }
    
    public func indexOfMessage(message: MessageViewModel) -> Int? {
        return find(messageVMs) { $0 === message }
    }
}

extension ConversationViewModel : NSFetchedResultsControllerDelegate {
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Update:
                break
        default:
            reloadNeeded = true
        }
    }
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        assert(NSThread.isMainThread(), "Main only")
        if reloadNeeded {
            reloadData()
        }
        reloadNeeded = false
    }
}