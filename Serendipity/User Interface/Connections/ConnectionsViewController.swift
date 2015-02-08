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
    
    var viewModel : FetchViewModel!
    var currentConnection : Connection?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sortDescriptor = NSSortDescriptor(key: ConnectionAttributes.dateUpdated.rawValue, ascending: false)
        viewModel = FetchViewModel(frc: Connection.all().sorted(by: sortDescriptor).frc())
        viewModel.bindToTableView(tableView, cellNibName: "ConnectionCell")
        viewModel.tableViewProvider?.configureTableCell = { (item, cell) -> Void in
            (cell as ConnectionCell).connection = (item as Connection)
        }
        viewModel.tableViewProvider?.didSelectItem = { item in
            self.currentConnection = item as? Connection
            println("Selected connection \(self.currentConnection?.user?.firstName)")
            self.performSegueWithIdentifier("ConnectionsToChat", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ChatViewController {
            vc.connection = self.currentConnection
        }
    }
}
