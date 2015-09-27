//
//  UITableViewBinding.swift
//  S10
//
//  Created by Tony Xiao on 9/26/15.
//  Copyright © 2015 S10. All rights reserved.
//

import UIKit
import ReactiveCocoa

public class TableViewBinding<Source: ArrayPropertyType> : NSObject, UITableViewDataSource {
    
    public private(set) weak var tableView: UITableView?
    public var source: Source?
    
    let rowAnimation: UITableViewRowAnimation
    
    init(tableView: UITableView, rowAnimation: UITableViewRowAnimation = .Automatic) {
        self.tableView = tableView
        self.rowAnimation = rowAnimation
        super.init()
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
    
    func bind(source: Source) {
        self.source = source
        tableView?.reloadData()
        source.changes.observeNext { [weak self] operation in
            self?.performOperation(operation)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    @objc public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source?.array.count ?? 0
    }
    
    @objc public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

//extension UITableView {
//    private struct AssociatedKeys {
//        static var BindingKey = "bindingKey"
//    }
//}