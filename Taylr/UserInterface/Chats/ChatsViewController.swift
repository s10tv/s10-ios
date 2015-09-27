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
import DZNEmptyDataSet

class ChatsViewController : BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let vm: ChatsViewModel = ChatsViewModel(meteor: Meteor, taskService: Globals.taskService)
    
    deinit {
        tableView?.emptyDataSetSource = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0.01))
        tableView.emptyDataSetSource = self
        
        tableView.bindTo(vm.connections, cell: ContactConnectionCell.self)
        vm.connections.changes.observeNext { [weak self] _ in
            self?.tableView.reloadEmptyDataSet()
        }
        
        listenForNotification(DidTouchStatusBar).startWithNext { [weak self] _ in
            self?.tableView.scrollToTop(animated: true)
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Globals.analyticsService.screen("Chats")
        AudioController.sharedController.checkMuteSwitch() // Early mute switch check
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ConversationViewController {
            vc.vm = vm.conversationVM(tableView.indexPathForSelectedRow!.row)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset = UIEdgeInsets(top: topLayoutGuide.length, left: 0,
                                           bottom: bottomLayoutGuide.length, right: 0)
    }
}

extension ChatsViewController : DZNEmptyDataSetSource {
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let message = LS(.emptyContactsMessage)
        return NSAttributedString(string: message, attributes: [
            NSFontAttributeName: UIFont(.cabinRegular, size: 20)
        ])
    }
}
