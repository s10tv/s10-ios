//
//  FetchViewModel.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/7/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import ReactiveCocoa
import CoreData

class FetchViewModel : NSFetchedResultsControllerDelegate, ProviderDelegate {
    
    let signal = RACReplaySubject(capacity: 1)
    var frc : NSFetchedResultsController {
        didSet {
            oldValue.delegate = nil
            frc.delegate = self
            refreshViews()
        }
    }
    var objects : [AnyObject] {
        performFetchIfNeeded()
        return frc.fetchedObjects!
    }
    var selectedObject : AnyObject?
    
    var tableViewProvider : TableViewProvider?
    var collectionViewProvider : CollectionViewProvider?
    
    
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
    
    func refreshViews() {
        self.tableViewProvider?.tableView.reloadData()
        self.collectionViewProvider?.collectionView.reloadData()
    }
    
    // MARK: - NSFetchedResultsController Delegate
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        signal.sendNext(objects)
        refreshViews()
    }
    
    // MARK: - Table & Collection Bindings
    
    func bindToTableView(tableView: UITableView, cellNibName: String) {
        performFetchIfNeeded()
        tableViewProvider = TableViewProvider(delegate: self, tableView: tableView, cellNibName: cellNibName)
    }
    
    func bindToCollectionView(collectionView: UICollectionView, cellNibName: String) {
        performFetchIfNeeded()
        collectionViewProvider = CollectionViewProvider(delegate: self, collectionView: collectionView, cellNibName: cellNibName)
    }
    
    // MARK: Provider Delegate
    
    func numberOfSections() -> Int {
        return frc.sections!.count
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        return (frc.sections![section] as NSFetchedResultsSectionInfo).numberOfObjects
    }
    
    func itemAtIndexPath(indexPath: NSIndexPath) -> AnyObject {
        return frc.objectAtIndexPath(indexPath)
    }

    func didSelectIndexPath(indexPath: NSIndexPath) {
        selectedObject = frc.objectAtIndexPath(indexPath)
    }
}
