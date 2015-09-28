//
//  DynamicDataSource.swift
//  S10
//
//  Created by Tony Xiao on 7/26/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import ReactiveCocoa

public protocol BindableCell {
    typealias ViewModel
    func bind(vm: ViewModel)
    static func reuseId() -> String
}

// MARK: - UITableView

extension UITableView {
    public func dequeue<C: BindableCell, VM where C.ViewModel == VM>(cell: C.Type, indexPath: NSIndexPath, vm: VM? = nil) -> C {
        let cell = dequeueReusableCellWithIdentifier(cell.reuseId(), forIndexPath: indexPath) as! C
        if let vm = vm {
            cell.bind(vm)
        }
        return cell
    }
}

public func <~ <Source: ArrayPropertyType, C: BindableCell where Source.ElementType == C.ViewModel>(tableView: UITableView, tuple: (source: Source, cell: C.Type)) -> Disposable {
    let reuseId = tuple.cell.reuseId()
    tableView.bindTo(tuple.source) { collectionView, vm, row in
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseId, forIndexPath: NSIndexPath(forRow: row, inSection: 0))
        (cell as! C).bind(vm)
        return cell
    }
    return ActionDisposable {
        tableView.unbind()
    }
}

// MARK: - UICollectionView

extension UICollectionView {
    public func dequeue<C: BindableCell, VM where C.ViewModel == VM>(cell: C.Type, indexPath: NSIndexPath, vm: VM? = nil) -> C {
        let cell = dequeueReusableCellWithReuseIdentifier(cell.reuseId(), forIndexPath: indexPath) as! C
        if let vm = vm {
            cell.bind(vm)
        }
        return cell
    }
}

public func <~ <Source: ArrayPropertyType, C: BindableCell where Source.ElementType == C.ViewModel>(collectionView: UICollectionView, tuple: (source: Source, cell: C.Type)) -> Disposable {
    let reuseId = tuple.cell.reuseId()
    collectionView.bindTo(tuple.source) { collectionView, vm, item in
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseId, forIndexPath: NSIndexPath(forItem: item, inSection: 0))
        (cell as! C).bind(vm)
        return cell
    }
    return ActionDisposable {
        collectionView.unbind()
    }
}
