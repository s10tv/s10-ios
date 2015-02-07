//
//  ArrayViewModel.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/5/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit

class ArrayViewModel<T> : ProviderDelegate {

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
    
    // Mark - Provider Delegate
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        return content.count
    }
    
    func itemAtIndexPath(indexPath: NSIndexPath) -> Any {
        return content[indexPath.row] as Any
    }
    
    func didSelectIndexPath(indexPath: NSIndexPath) {
        selectedItem = content[indexPath.row]
    }
}

protocol ProviderDelegate {
    func numberOfSections() -> Int
    func numberOfItemsInSection(section: Int) -> Int
    func itemAtIndexPath(indexPath: NSIndexPath) -> Any
    func didSelectIndexPath(indexPath: NSIndexPath)
}

// MARK: - CollectionView Support

class CollectionViewProvider : NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    typealias ConfigureCollectionCellBlock = (item : Any, cell : UICollectionViewCell) -> Void
    let delegate : ProviderDelegate
    let collectionView : UICollectionView
    let cellNibName : String
    var configureCollectionCell : ConfigureCollectionCellBlock?
    var didSelectItem : ((item : Any) -> Void)?
    
    init(delegate: ProviderDelegate, collectionView: UICollectionView, cellNibName: String) {
        // TODO: Can we use generic here and do better than UITableViewCell?
        self.delegate = delegate
        self.collectionView = collectionView
        self.cellNibName = cellNibName
        super.init()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerNib(UINib(nibName: cellNibName, bundle: nil), forCellWithReuseIdentifier: cellNibName)
    }
    
    // MARK: CollectionView DataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate.numberOfItemsInSection(section)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellNibName, forIndexPath: indexPath) as UICollectionViewCell
        configureCollectionCell?(item: delegate.itemAtIndexPath(indexPath), cell: cell)
        return cell
    }
    
}

// MARK: - TableView Support

class TableViewProvider : NSObject, UITableViewDelegate, UITableViewDataSource {
    typealias ConfigureTableCellBlock = (item : Any, cell : UITableViewCell) -> Void
    let delegate : ProviderDelegate
    let tableView : UITableView
    let cellNibName : String
    var configureTableCell : ConfigureTableCellBlock?
    var didSelectItem : ((item : Any) -> Void)?
    
    init(delegate: ProviderDelegate, tableView: UITableView, cellNibName: String) {
        // TODO: Can we use generic here and do better than UITableViewCell?
        self.delegate = delegate
        self.tableView = tableView
        self.cellNibName = cellNibName
        super.init()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: cellNibName, bundle: nil), forCellReuseIdentifier: cellNibName)
    }
    
    // MARK: TableView DataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate.numberOfItemsInSection(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellNibName, forIndexPath: indexPath) as UITableViewCell
        configureTableCell?(item: delegate.itemAtIndexPath(indexPath), cell: cell)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        didSelectItem?(item: delegate.itemAtIndexPath(indexPath))
    }
}
