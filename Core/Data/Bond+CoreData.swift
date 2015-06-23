//
//  Bond+CoreData.swift
//  S10
//
//  Created by Tony Xiao on 6/22/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import CoreData
import Bond

private var sectionsDynamicHandleNSFetchedResultsController: UInt8 = 0;
private var delegateDynamicHandleNSFetchedResultsController: UInt8 = 0;

extension NSFetchedResultsController {

    public var dynSections: DynamicArray<DynamicArray<NSManagedObject>> {
        if let d: AnyObject = objc_getAssociatedObject(self, &sectionsDynamicHandleNSFetchedResultsController) {
            return (d as? DynamicArray<DynamicArray<NSManagedObject>>)!
        } else {
            let d = DynamicArray<DynamicArray<NSManagedObject>>([DynamicArray([])])
            dynDelegate.sections = d
            dynDelegate.nextDelegate = delegate
            delegate = dynDelegate
            objc_setAssociatedObject(self, &sectionsDynamicHandleNSFetchedResultsController, d, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            return d
        }
    }
    
    public var nextDelegate: NSFetchedResultsControllerDelegate? {
        get { return dynDelegate.nextDelegate }
        set { dynDelegate.nextDelegate = newValue }
    }
    
    var dynDelegate: FetchedResultsControllerDynamicDelegate {
        if let d: AnyObject = objc_getAssociatedObject(self, &delegateDynamicHandleNSFetchedResultsController) {
            return (d as? FetchedResultsControllerDynamicDelegate)!
        } else {
            let d = FetchedResultsControllerDynamicDelegate()
            objc_setAssociatedObject(self, &delegateDynamicHandleNSFetchedResultsController, d, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            return d
        }
    }
}

@objc class FetchedResultsControllerDynamicDelegate : NSObject {
    weak var sections: DynamicArray<DynamicArray<NSManagedObject>>?
    @objc weak var nextDelegate: NSFetchedResultsControllerDelegate?
}

extension FetchedResultsControllerDynamicDelegate : NSFetchedResultsControllerDelegate {
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            sections?[newIndexPath!.section].insert(anObject as! NSManagedObject, atIndex: newIndexPath!.row)
        case .Delete:
            sections?[indexPath!.section].removeAtIndex(indexPath!.row)
        case .Update:
            sections?[indexPath!.section][indexPath!.row] = anObject as! NSManagedObject
        case .Move:
            sections?[indexPath!.section].removeAtIndex(indexPath!.row)
            sections?[newIndexPath!.section].insert(anObject as! NSManagedObject, atIndex: newIndexPath!.row)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            sections?.insert(DynamicArray([]), atIndex: sectionIndex)
        case .Delete:
            sections?.removeAtIndex(sectionIndex)
        default:
            fatalError("Received impossible NSFetchedResultsChangeType \(type)")
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        nextDelegate?.controllerWillChangeContent?(controller)
    }
    
    func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String?) -> String? {
        return nextDelegate?.controller?(controller, sectionIndexTitleForSectionName: sectionName)
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        nextDelegate?.controllerDidChangeContent?(controller)
    }
}
