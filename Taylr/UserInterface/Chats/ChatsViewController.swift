//
//  ChatsViewController.swift
//  Taylr
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import Core
import Bond

class ChatsViewController : BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var chatsVM : ChatsViewModel!
    var dataSourceBond: UITableViewDataSourceBond<UITableViewCell>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSourceBond = UITableViewDataSourceBond(tableView: tableView, disableAnimation: false)
        chatsVM = ChatsViewModel()
        chatsVM.connections.map { [unowned self] (connection, index) -> UITableViewCell in
            let cell = self.tableView.dequeueReusableCellWithIdentifier("ConnectionCell",
                forIndexPath: NSIndexPath(forRow: index, inSection: 0)) as! ConnectionCell
            cell.connection = connection
            return cell
        } ->> dataSourceBond
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ProfileViewController {
            vc.user = ((sender as! UIGestureRecognizer).view as! UserAvatarView).user
        }
        if let vc = segue.destinationViewController as? ConversationViewController {
            let conn = chatsVM.connections[tableView.indexPathForSelectedRow()!.row]
            vc.viewModel = ConversationViewModel(connection: conn)
        }
    }
    
    override func handleScreenEdgePan(edge: UIRectEdge) -> Bool {
        Log.debug("Handding to edge \(edge) from dockVC")
        if edge == .Left {
            performSegue(.ChatsToDiscover)
            return true
        }
        return super.handleScreenEdgePan(edge)
    }
}