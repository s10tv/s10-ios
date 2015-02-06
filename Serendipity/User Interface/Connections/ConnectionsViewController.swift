//
//  ConnectionsViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit

@objc(ConnectionsViewController)
class ConnectionsViewController : BaseViewController {
    
    let viewModel = ArrayViewModel(content: [Connection]())
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.content = Connection.MR_findAll() as [Connection]
        viewModel.bindToTableView(tableView, cellNibName: "ConnectionCell")
        viewModel.tableViewProvider?.configureTableCell = { (item, cell) -> Void in
            (cell as ConnectionCell).connection = (item as Connection)
        }
        viewModel.tableViewProvider?.didSelectItem = { item in
            let conn = item as Connection
            println("Selected connection \(conn.user?.firstName)")
            self.performSegueWithIdentifier("ConnectionsToChat", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ChatViewController {
            vc.connection = viewModel.selectedItem
        }
    }
}
