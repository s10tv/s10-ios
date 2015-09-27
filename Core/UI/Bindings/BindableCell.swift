//
//  DynamicDataSource.swift
//  S10
//
//  Created by Tony Xiao on 7/26/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit

public protocol BindableCell {
    typealias ViewModel
    func bind(vm: ViewModel)
    static func reuseId() -> String
}

extension UITableView {
    public func dequeue<C: BindableCell, VM where C.ViewModel == VM>(cell: C.Type, indexPath: NSIndexPath, vm: VM? = nil) -> C {
        let cell = dequeueReusableCellWithIdentifier(cell.reuseId(), forIndexPath: indexPath) as! C
        if let vm = vm {
            cell.bind(vm)
        }
        return cell
    }
    
    public func bindTo<Source: ArrayPropertyType, C: BindableCell where Source.ElementType == C.ViewModel>(source: Source, cell: C.Type) -> TableViewBinding<Source, Source.ElementType> {
        let reuseId = cell.reuseId()
        return bindTo(source) { tableView, vm, row in
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseId, forIndexPath: NSIndexPath(forRow: row, inSection: 0))
            (cell as! C).bind(vm)
            return cell
        }
    }
}

extension UICollectionView {
    public func dequeue<C: BindableCell, VM where C.ViewModel == VM>(cell: C.Type, indexPath: NSIndexPath, vm: VM? = nil) -> C {
        let cell = dequeueReusableCellWithReuseIdentifier(cell.reuseId(), forIndexPath: indexPath) as! C
        if let vm = vm {
            cell.bind(vm)
        }
        return cell
    }
    
    public func bindTo<Source: ArrayPropertyType, C: BindableCell where Source.ElementType == C.ViewModel>(source: Source, cell: C.Type) -> CollectionViewBinding<Source, Source.ElementType> {
        let reuseId = cell.reuseId()
        return bindTo(source) { collectionView, vm, row in
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseId, forIndexPath: NSIndexPath(forRow: row, inSection: 0))
            (cell as! C).bind(vm)
            return cell
        }
    }
}
