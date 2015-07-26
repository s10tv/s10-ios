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
    let vm: ChatsViewModel = ChatsViewModel(meteor: Meteor)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.contactsConnections.map { [unowned self] (vm, index) -> UITableViewCell in
            let cell = self.tableView.dequeueReusableCellWithIdentifier(.ConnectionCell,
                forIndexPath: NSIndexPath(forRow: index, inSection: 0)) as! ConnectionCell
            cell.bindViewModel(vm)
            return cell
        } ->> tableView
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ConversationViewController {
            vc.vm = vm.conversationVM(tableView.indexPathForSelectedRow()!.row)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset = UIEdgeInsets(top: topLayoutGuide.length, left: 0,
                                           bottom: bottomLayoutGuide.length, right: 0)
    }
}