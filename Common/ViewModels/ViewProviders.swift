//
//  ViewProviders.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/7/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit

protocol ProviderDelegate {
    func numberOfSections() -> Int
    func numberOfItemsInSection(section: Int) -> Int
    func itemAtIndexPath(indexPath: NSIndexPath) -> AnyObject
    func didSelectIndexPath(indexPath: NSIndexPath)
}

// MARK: - CollectionView Support

class CollectionViewProvider : NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    typealias ConfigureCollectionCellBlock = (item : AnyObject, cell : UICollectionViewCell) -> Void
    let delegate : ProviderDelegate
    let collectionView : UICollectionView
    let cellNibName : String
    var configureCollectionCell : ConfigureCollectionCellBlock?
    var didSelectItem : ((item : AnyObject) -> Void)?
    
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
    
    // MARK: CollectionView Delegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        didSelectItem?(item: delegate.itemAtIndexPath(indexPath))
    }
    
}

// MARK: - TableView Support

class TableViewProvider : NSObject, UITableViewDelegate, UITableViewDataSource {
    typealias ConfigureTableCellBlock = (item : AnyObject, cell : UITableViewCell) -> Void
    let delegate : ProviderDelegate
    let tableView : UITableView
    let cellNibName : String
    var configureTableCell : ConfigureTableCellBlock?
    var didSelectItem : ((item : AnyObject) -> Void)?
    
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

    // MARK: TableView Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        didSelectItem?(item: delegate.itemAtIndexPath(indexPath))
    }
}
