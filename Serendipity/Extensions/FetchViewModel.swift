//
//  FetchViewModel.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/7/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import ReactiveCocoa
import CoreData

class FetchViewModel : NSFetchedResultsControllerDelegate {
    
    let frc : NSFetchedResultsController
    let signal = RACReplaySubject(capacity: 1)
    var objects : [AnyObject] {
        performFetchIfNeeded()
        return frc.fetchedObjects!
    }
    
    init(frc: NSFetchedResultsController) {
        self.frc = frc
        frc.delegate = self
    }
    
    func addSortKey(key: String, ascending: Bool) {
        var sortDescriptors = frc.fetchRequest.sortDescriptors ?? []
        sortDescriptors.append(NSSortDescriptor(key: key, ascending: ascending))
        frc.fetchRequest.sortDescriptors = sortDescriptors
    }
    
    func performFetchIfNeeded() {
        // TODO: Make class thread-safe
        assert(NSThread.isMainThread(), "Only main thread access is support for now")
        if frc.fetchedObjects == nil {
            var error : NSError?
            let fetched = frc.performFetch(&error)
            if !fetched || error != nil {
                println("Problem encountered white fetching \(error)")
            }
            signal.sendNext(frc.fetchedObjects!)
        }
    }
    
    // MARK: - NSFetchedResultsController Delegate
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        signal.sendNext(objects)
    }
}
