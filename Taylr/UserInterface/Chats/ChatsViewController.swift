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
    var chatsVM : ChatsInteractor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatsVM = ChatsInteractor()
        chatsVM.connectionViewModels.map { [unowned self] (connectionVM, index) -> UITableViewCell in
            let cell = self.tableView.dequeueReusableCellWithIdentifier(.ConnectionCell,
                forIndexPath: NSIndexPath(forRow: index, inSection: 0)) as! ConnectionCell
            cell.viewModel = connectionVM
            return cell
        } ->> tableView
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ConversationViewController {
            vc.conversationVM = chatsVM.connectionViewModels[tableView.indexPathForSelectedRow()!.row]
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset = UIEdgeInsets(top: topLayoutGuide.length, left: 0,
                                           bottom: bottomLayoutGuide.length, right: 0)
    }
}