//
//  ChatsViewController.swift
//  Taylr
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import Core

class ChatsViewController : BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var chatsVM : ChatsViewModel!
    
    override func viewDidLoad() {
        chatsVM = ChatsViewModel()
        chatsVM.bindTableView(tableView)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ProfileViewController {
            vc.user = ((sender as! UIGestureRecognizer).view as! UserAvatarView).user
        }
        if let vc = segue.destinationViewController as? ConversationViewController {
            let conn = chatsVM.itemAtIndexPath(tableView.indexPathForSelectedRow()!)
            vc.vm = ConversationViewModel(connection: conn!)
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