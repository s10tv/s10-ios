//
//  BondExtensions.swift
//  S10
//
//  Created by Tony Xiao on 6/22/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import CoreData
import Bond

public func unbindAll<U: Bondable>(bondables: U...) {
    for bondable in bondables {
        bondable.designatedBond.unbindAll()
    }
}

// MARK: - Dynamic Support

public func dynamicValueFor<T>(object: NSObject, keyPath: String, defaultValue: T? = nil) -> Dynamic<T?> {
    return dynamicObservableFor(object, keyPath: keyPath, from: { (value: AnyObject?) -> T? in
        return value as? T
        }, to: { (value: T?) -> AnyObject? in
            return value as? AnyObject
    })
}

public extension NSObject {
    public func dynValue<T>(keyPath: String, _ defaultValue: T? = nil) -> Dynamic<T?> {
        return dynamicValueFor(self, keyPath, defaultValue: defaultValue)
    }
    public func dynValue<T>(keyPath: Printable, _ defaultValue: T? = nil) -> Dynamic<T?> {
        return dynValue(keyPath.description, defaultValue)
    }
}

// MARK: - UIKit

private var activeDynamicHandleNSLayoutConstraint: UInt8 = 0;

extension NSLayoutConstraint {
    public var dynActive: Dynamic<Bool> {
        if let d: AnyObject = objc_getAssociatedObject(self, &activeDynamicHandleNSLayoutConstraint) {
            return (d as? Dynamic<Bool>)!
        } else {
            let d = InternalDynamic<Bool>(self.active)
            let bond = Bond<Bool>() { [weak self] v in if let s = self { s.active = v } }
            d.bindTo(bond, fire: false, strongly: false)
            d.retain(bond)
            objc_setAssociatedObject(self, &activeDynamicHandleNSLayoutConstraint, d, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            return d
        }
    }
}

// MARK: - CoreData

private var sectionsDynamicHandleNSFetchedResultsController: UInt8 = 0;
private var countDynamicHandleNSFetchedResultsController: UInt8 = 0;
private var delegateDynamicHandleNSFetchedResultsController: UInt8 = 0;

extension NSFetchedResultsController {

    public var dynSections: DynamicArray<DynamicArray<NSManagedObject>> {
        if let d: AnyObject = objc_getAssociatedObject(self, &sectionsDynamicHandleNSFetchedResultsController) {
            return (d as? DynamicArray<DynamicArray<NSManagedObject>>)!
        } else {
            var error: NSError?
            if !performFetch(&error) {
                fatalError("Unable to perform fetch for request \(fetchRequest)")
            }
            let d = DynamicArray(sections!.map {
                DynamicArray(($0 as! NSFetchedResultsSectionInfo).objects.map { $0 as! NSManagedObject })
            })
            dynDelegate.sections = d
            if dynDelegate.nextDelegate == nil {
                dynDelegate.nextDelegate = delegate
            }
            delegate = dynDelegate
            objc_setAssociatedObject(self, &sectionsDynamicHandleNSFetchedResultsController, d, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            return d
        }
    }
    
    public var dynCount: Dynamic<Int> {
        if let d: AnyObject = objc_getAssociatedObject(self, &countDynamicHandleNSFetchedResultsController) {
            return (d as? Dynamic<Int>)!
        } else {
            var error: NSError?
            if !performFetch(&error) {
                fatalError("Unable to perform fetch for request \(fetchRequest)")
            }
            let d = Dynamic<Int>(0)
            dynDelegate.count = d
            if dynDelegate.nextDelegate == nil {
                dynDelegate.nextDelegate = delegate
            }
            delegate = dynDelegate
            objc_setAssociatedObject(self, &countDynamicHandleNSFetchedResultsController, d, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
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
    weak var count: Dynamic<Int>?
    @objc weak var nextDelegate: NSFetchedResultsControllerDelegate?
}

extension FetchedResultsControllerDynamicDelegate : NSFetchedResultsControllerDelegate {
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        assert(NSThread.isMainThread(), "Should only happen on main thread")
        switch type {
        case .Insert:
            Log.verbose("\(unsafeAddressOf(self)) Will insert object at index \(newIndexPath)")
            sections?[newIndexPath!.section].insert(anObject as! NSManagedObject, atIndex: newIndexPath!.row)
        case .Delete:
            Log.verbose("\(unsafeAddressOf(self)) Will delete object at index \(indexPath)")
            sections?[indexPath!.section].removeAtIndex(indexPath!.row)
        case .Update:
            Log.verbose("\(unsafeAddressOf(self)) Will update object at index \(indexPath)")
            sections?[indexPath!.section][indexPath!.row] = anObject as! NSManagedObject
        case .Move:
            Log.verbose("\(unsafeAddressOf(self)) Will move object from \(indexPath) to \(newIndexPath)")
            sections?[indexPath!.section].removeAtIndex(indexPath!.row)
            sections?[newIndexPath!.section].insert(anObject as! NSManagedObject, atIndex: newIndexPath!.row)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        assert(NSThread.isMainThread(), "Should only happen on main thread")
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
        assert(NSThread.isMainThread(), "Has to run on main")
        count?.value = controller.fetchedObjects?.count ?? 0
        nextDelegate?.controllerDidChangeContent?(controller)
    }
}

// MARK: - UINavigationItem

private var titleDynamicHandleUINavigationItem: UInt8 = 0;

extension UINavigationItem : Bondable {
    public var dynTitle: Dynamic<String> {
        if let d: AnyObject = objc_getAssociatedObject(self, &titleDynamicHandleUINavigationItem) {
            return (d as? Dynamic<String>)!
        } else {
            let d = InternalDynamic<String>(self.title ?? "")
            let bond = Bond<String>() { [weak self] v in if let s = self { s.title = v } }
            d.bindTo(bond, fire: false, strongly: false)
            d.retain(bond)
            objc_setAssociatedObject(self, &titleDynamicHandleUINavigationItem, d, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            return d
        }
    }
    
    public var designatedBond: Bond<String> {
        return self.dynTitle.valueBond
    }
}