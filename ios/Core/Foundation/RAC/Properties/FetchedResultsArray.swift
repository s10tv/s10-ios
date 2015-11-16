//
//  FetchedResultsArray.swift
//  S10
//
//  Created by Tony Xiao on 9/26/15.
//  Copyright © 2015 S10. All rights reserved.
//

import CoreData
import ReactiveCocoa

public class FetchedResultsArray<T>: ArrayPropertyType {
    private let frcDelegate: FetchedResultsControllerArrayDelegate
    private let transform: AnyObject -> T
    private let changesSink: Event<ArrayOperation, NoError>.Sink
    private var objects: [AnyObject] {
        return frc.fetchedObjects ?? []
    }
    
    public typealias ElementType = T
    public let frc: NSFetchedResultsController
    public let predicate: MutableProperty<NSPredicate?>
    
    public var array: [T] {
        return objects.map(transform)
    }
    public subscript(index: Int) -> T {
        return transform(objects[index])
    }
    public let changes: Signal<ArrayOperation, NoError>
    
    public init(frc: NSFetchedResultsController, transform: AnyObject -> ElementType) {
        self.frc = frc
        self.transform = transform
        self.predicate = MutableProperty(frc.fetchRequest.predicate)
        (changes, changesSink) = Signal<ArrayOperation, NoError>.pipe()
        frcDelegate = FetchedResultsControllerArrayDelegate(frc: frc, sink: changesSink)
        
        predicate.producer.startWithNext { [weak self] pred in
            self?.frc.fetchRequest.predicate = pred
            self?.reloadData()
        }
    }
    
    public func reloadData() {
        NSFetchedResultsController.deleteCacheWithName(frc.cacheName)
        do {
            try frc.performFetch()
        } catch {
            print("***** Error fetching \(frc.fetchRequest) \(error) *****")
        }
        sendNext(changesSink, .Reset)
    }
    
    deinit {
        sendCompleted(changesSink)
    }
}

// MARK: - FetchResultsControllerArrayDelegate

@objc class FetchedResultsControllerArrayDelegate : NSObject {
    let sink: Event<ArrayOperation, NoError>.Sink
    @objc weak var nextDelegate: NSFetchedResultsControllerDelegate?
    var batchedOperations: [ArrayOperation] = []
    
    init(frc: NSFetchedResultsController, sink: Event<ArrayOperation, NoError>.Sink) {
        self.sink = sink
        self.nextDelegate = frc.delegate
        super.init()
        frc.delegate = self
    }
}

extension FetchedResultsControllerArrayDelegate : NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        batchedOperations = []
        nextDelegate?.controllerWillChangeContent?(controller)
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        nextDelegate?.controller?(controller, didChangeSection: sectionInfo, atIndex: sectionIndex, forChangeType: type)
        print("WARNING: Fetched Results with sections is not yet supported. Please add pull request :)")
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        assert(NSThread.isMainThread(), "Should only happen on main thread")
        switch type {
        case .Insert:
            batchedOperations.append(.Insert(newIndexPath!.row))
        case .Delete:
            batchedOperations.append(.Delete(indexPath!.row))
        case .Update:
            batchedOperations.append(.Update(indexPath!.row))
        case .Move:
            // TODO: Native move implementation?
            batchedOperations.append(.Insert(newIndexPath!.row))
            batchedOperations.append(.Delete(indexPath!.row))
        }
        nextDelegate?.controller?(controller, didChangeObject: anObject, atIndexPath: indexPath, forChangeType: type, newIndexPath: newIndexPath)
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        assert(NSThread.isMainThread(), "Has to run on main")
        sendNext(sink, .Batch(batchedOperations))
        batchedOperations.removeAll()
        nextDelegate?.controllerDidChangeContent?(controller)
    }
    
    func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return nextDelegate?.controller?(controller, sectionIndexTitleForSectionName: sectionName)
    }
}
