//
//  ArrayViewModel.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/5/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit


class ArrayViewModel<T> : NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var content : [T] = [] {
        didSet {
            tableView?.reloadData()
        }
    }
    
    // MARK: - TableView Support
    
    var tableView : UITableView?
    var cellNibName : String?
    var configureTableCell : ((object : T, cell : UITableViewCell) -> Void)?
    
    func bindTableView(tableView: UITableView, cellNibName: String, configureBlock: (object : T, cell : UITableViewCell) -> Void) {
        self.tableView = tableView
        self.cellNibName = cellNibName
        self.configureTableCell = configureBlock
        tableView.delegate = self
        tableView.dataSource = self
        // NOTE: Assuming cell has xib for the moment
        tableView.registerNib(UINib(nibName: cellNibName, bundle: nil), forCellReuseIdentifier: cellNibName)
    }
    
    // MARK: TableView DataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellNibName!, forIndexPath: indexPath) as UITableViewCell
        let object = content[indexPath.row]
        configureTableCell?(object: object, cell: cell)
        return cell
    }
}