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
    
    @IBOutlet weak var keepTable: UITableView!
    @IBOutlet weak var marryTable: UITableView!

    var keeps : FetchViewModel!
    var marrys : FetchViewModel!
    var currentConnection : Connection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sortDescriptor = NSSortDescriptor(key: ConnectionAttributes.updatedAt.rawValue, ascending: false)
        
        keeps = FetchViewModel(frc: Connection.by(ConnectionAttributes.type.rawValue, value: "maybe").sorted(by: sortDescriptor).frc())
        keeps.bindToTableView(keepTable, cellNibName: "KeepConnectionCell")
        keeps.tableViewProvider?.configureTableCell = { (item, cell) -> Void in
            (cell as ConnectionCell).connection = (item as Connection)
        }
        keeps.tableViewProvider?.didSelectItem = self.didSelectItem
        
        marrys = FetchViewModel(frc: Connection.by(ConnectionAttributes.type.rawValue, value: "yes").sorted(by: sortDescriptor).frc())
        marrys.bindToTableView(marryTable, cellNibName: "MarryConnectionCell")
        marrys.tableViewProvider?.configureTableCell = { (item, cell) -> Void in
            (cell as ConnectionCell).connection = (item as Connection)
        }
        marrys.tableViewProvider?.didSelectItem = self.didSelectItem
    }

    func didSelectItem(item: AnyObject!) {
        self.currentConnection = item as? Connection
        println("Selected connection \(self.currentConnection?.user?.firstName)")
        self.performSegue(.DockToChat)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ChatViewController {
            vc.connection = currentConnection
            Core.meteor.callMethod("connection/markAsRead", params: [(currentConnection?.documentID)!])
        }
    }
    
    @IBAction func goBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }




}
