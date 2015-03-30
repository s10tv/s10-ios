//
//  ConnectionsViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit

@objc(DockViewController)
class DockViewController : BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var connections : FetchViewModel!
    var currentConnection : Connection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sortDescriptor = NSSortDescriptor(key: ConnectionAttributes.updatedAt.rawValue, ascending: false)
        
        connections = FetchViewModel(frc: Connection.by(ConnectionAttributes.type.rawValue, value: "yes").sorted(by: sortDescriptor).frc())
        connections.bindToTableView(tableView, cellNibName: "ConnectionCell")
        connections.tableViewProvider?.configureTableCell = { (item, cell) -> Void in
            (cell as ConnectionCell).connection = (item as Connection)
        }
        connections.tableViewProvider?.didSelectItem = self.didSelectItem
    }

    func didSelectItem(item: AnyObject!) {
        self.currentConnection = item as? Connection
        println("Selected connection \(self.currentConnection?.user?.displayName)")
        self.performSegue(.DockToChat)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ChatViewController {
            vc.connection = currentConnection
            Core.meteor.callMethod("connection/markAsRead", params: [(currentConnection?.documentID)!])
        }
    }
    
}
