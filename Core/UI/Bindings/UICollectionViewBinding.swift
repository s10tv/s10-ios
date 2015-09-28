//
//  UICollectionViewBinding.swift
//  S10
//
//  Created by Tony Xiao on 9/26/15.
//  Copyright © 2015 S10. All rights reserved.
//

import UIKit
import ReactiveCocoa

public class CollectionViewBinding<Source: ArrayPropertyType, T where Source.ElementType == T> : NSObject, UICollectionViewDataSource {
    public typealias CellFactory = ((UICollectionView, T, Int) -> UICollectionViewCell)
    
    public private(set) weak var collectionView: UICollectionView?
    public var source: Source?
    public var createCell: CellFactory?
    
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        collectionView.dataSource = self
    }
    
    func performOperation(operation: ArrayOperation) {
        switch operation {
        case .Reset:
            collectionView?.reloadData()
        case .Insert(let row):
            collectionView?.insertItemsAtIndexPaths([NSIndexPath(forRow: row, inSection: 0)])
        case .Delete(let row):
            collectionView?.deleteItemsAtIndexPaths([NSIndexPath(forRow: row, inSection: 0)])
        case .Update(let row):
            collectionView?.reloadItemsAtIndexPaths([NSIndexPath(forRow: row, inSection: 0)])
        case .Batch(let operations):
            collectionView?.performBatchUpdates({
                operations.forEach { self.performOperation($0) }
            }, completion: nil)
        }
    }
    
    func bind(source: Source, createCell: CellFactory) {
        self.source = source
        self.createCell = createCell
        collectionView?.reloadData()
        source.changes.observeNext { [weak self] operation in
            self?.performOperation(operation)
        }
    }
    
    // MARK: - UICollectionViewDataSource

    @objc public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return source!.array.count
    }
    
    @objc public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return createCell!(collectionView, source![indexPath.row], indexPath.row)
    }
}

// MAJOR TODO: Figure out how to easily unbind, not just bind...
private var kCollectionBinding: UInt8 = 0;

extension UICollectionView {
    
    public var binding: AnyObject? { // TODO: Figure out a strongly typed way to do this
        get { return objc_getAssociatedObject(self, &kCollectionBinding) }
        set { objc_setAssociatedObject(self, &kCollectionBinding, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    public func bindTo<Source: ArrayPropertyType, T where Source.ElementType == T>(source: Source, createCell: (UICollectionView, T, Int) -> UICollectionViewCell) -> CollectionViewBinding<Source, T> {
        let binding = CollectionViewBinding<Source, T>(collectionView: self)
        binding.bind(source, createCell: createCell)
        self.binding = binding
        return binding
    }
    
    public func unbind() {
        self.binding = nil
        self.reloadData()
    }
}