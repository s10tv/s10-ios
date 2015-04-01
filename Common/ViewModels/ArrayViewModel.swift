//
//  ArrayViewModel.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/5/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit

class ArrayViewModel<T : AnyObject> {

    var content : [T]
    var selectedItem : T?
    var tableViewProvider : TableViewProvider?
    var collectionViewProvider : CollectionViewProvider?
    
    init(content: [T]) {
        self.content = content
    }
    
    func bindToTableView(tableView: UITableView, cellNibName: String) {
        tableViewProvider = TableViewProvider(delegate: self, tableView: tableView, cellNibName: cellNibName)
    }
    
    func bindToCollectionView(collectionView: UICollectionView, cellNibName: String) {
        collectionViewProvider = CollectionViewProvider(delegate: self, collectionView: collectionView, cellNibName: cellNibName)
    }
}

// Mark - Provider Delegate

extension ArrayViewModel : ProviderDelegate {
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        return content.count
    }
    
    func itemAtIndexPath(indexPath: NSIndexPath) -> AnyObject {
        return content[indexPath.row]
    }
    
    func didSelectIndexPath(indexPath: NSIndexPath) {
        selectedItem = content[indexPath.row]
    }
}