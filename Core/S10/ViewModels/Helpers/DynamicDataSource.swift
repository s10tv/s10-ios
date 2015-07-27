//
//  DynamicDataSource.swift
//  S10
//
//  Created by Tony Xiao on 7/26/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Bond

public protocol BindableCell {
    typealias ViewModel
    func bind(vm: ViewModel)
    static func reuseId() -> String
}

extension UITableView {
    public func factory<C: BindableCell, VM where C.ViewModel == VM>(cell: C.Type, section: Int = 0) -> (VM, Int) -> UITableViewCell {
        let reuseId = cell.reuseId()
        return { [unowned self] vm, row in
            let cell = self.dequeueReusableCellWithIdentifier(reuseId, forIndexPath: NSIndexPath(forRow: row, inSection: section)) as! UITableViewCell
            (cell as! C).bind(vm)
            return cell
        }
    }
}

extension UICollectionView {
    public func factory<C: BindableCell, VM where C.ViewModel == VM>(cell: C.Type, section: Int = 0) -> (VM, Int) -> UICollectionViewCell {
        let reuseId = cell.reuseId()
        return { [unowned self] vm, item in
            let cell = self.dequeueReusableCellWithReuseIdentifier(reuseId, forIndexPath: NSIndexPath(forItem: item, inSection: section)) as! UICollectionViewCell
            (cell as! C).bind(vm)
            return cell
        }
    }
}
