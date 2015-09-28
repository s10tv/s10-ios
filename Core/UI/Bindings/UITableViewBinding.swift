//
//  UITableViewBinding.swift
//  S10
//
//  Created by Tony Xiao on 9/26/15.
//  Copyright © 2015 S10. All rights reserved.
//

import UIKit
import ReactiveCocoa

public class TableViewBinding<Source: ArrayPropertyType, T where Source.ElementType == T> : NSObject, UITableViewDataSource {
    public typealias CellFactory = ((UITableView, T, Int) -> UITableViewCell)
    
    public private(set) weak var tableView: UITableView?
    public var source: Source?
    public var createCell: CellFactory?
    
    let rowAnimation: UITableViewRowAnimation
    
    init(tableView: UITableView, rowAnimation: UITableViewRowAnimation = .Automatic) {
        self.tableView = tableView
        self.rowAnimation = rowAnimation
        super.init()
        tableView.dataSource = self
    }
    
    func performOperation(operation: ArrayOperation) {
        switch operation {
        case .Reset:
            tableView?.reloadData()
        case .Insert(let row):
            tableView?.insertRowsAtIndexPaths([NSIndexPath(forRow: row, inSection: 0)], withRowAnimation: rowAnimation)
        case .Delete(let row):
            tableView?.deleteRowsAtIndexPaths([NSIndexPath(forRow: row, inSection: 0)], withRowAnimation: rowAnimation)
        case .Update(let row):
            tableView?.reloadRowsAtIndexPaths([NSIndexPath(forRow: row, inSection: 0)], withRowAnimation: rowAnimation)
        case .Batch(let operations):
            tableView?.beginUpdates()
            operations.forEach { self.performOperation($0) }
            tableView?.endUpdates()
        }
    }
    
    func bind(source: Source, createCell: CellFactory) {
        self.source = source
        self.createCell = createCell
        tableView?.reloadData()
        source.changes.observeNext { [weak self] operation in
            self?.performOperation(operation)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    @objc public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source!.array.count
    }
    
    @objc public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return createCell!(tableView, source![indexPath.row], indexPath.row)
    }
}

private var kTableBinding: UInt8 = 0;

extension UITableView {
    
    public var binding: AnyObject? { // TODO: Figure out a strongly typed way to do this
        get { return objc_getAssociatedObject(self, &kTableBinding) }
        set { objc_setAssociatedObject(self, &kTableBinding, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    public func bindTo<Source: ArrayPropertyType, T where Source.ElementType == T>(source: Source, createCell: (UITableView, T, Int) -> UITableViewCell) -> TableViewBinding<Source, T> {
        let binding = TableViewBinding<Source, T>(tableView: self)
        binding.bind(source, createCell: createCell)
        self.binding = binding
        return binding
    }
    
    public func unbind() {
        self.binding = nil
    }
}
