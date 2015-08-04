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
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    let vm: ChatsViewModel = ChatsViewModel(meteor: Meteor, taskService: Globals.taskService)
    let emptyDataBond = ArrayBond<ConnectionViewModel>()
    
    deinit {
        tableView.emptyDataSetSource = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0.01))
        tableView.emptyDataSetSource = self
        
        let contactCellFactory = tableView.factory(ContactConnectionCell)
        let newCellFactory = tableView.factory(NewConnectionCell)
        vm.connections.map { (vm, index) -> UITableViewCell in
            switch vm {
            case let vm as ContactConnectionViewModel:
                return contactCellFactory(vm, index)
            case let vm as NewConnectionViewModel:
                return newCellFactory(vm, index)
            default:
                fatalError("Unexpected cell type")
            }
        } ->> tableView
        vm.currentSection.producer.start(next: { [weak self] section in
            self?.segmentedControl.selectedSegmentIndex = section.rawValue
            switch section {
            case .Contacts:
                self?.tableView.rowHeight = 76
            case .New:
                self?.tableView.rowHeight = 120
            }
        })
        vm.connections.bindTo(emptyDataBond)
        emptyDataBond.didPerformBatchUpdatesListener = { [weak self] in
            self?.tableView.reloadEmptyDataSet()
        }
        
        vm.contactsUnreadCount.producer.start(next: { [weak self] count in
            let title = count > 0 ? "Contacts (\(count))" : "Contacts"
            self?.segmentedControl.setTitle(title, forSegmentAtIndex: 0)
        })
        vm.newUnreadCount.producer.start(next: { [weak self] count in
            let title = count > 0 ? "New (\(count))" : "New"
            self?.segmentedControl.setTitle(title, forSegmentAtIndex: 1)
        })
        
        listenForNotification(DidTouchStatusBar).start(next: { [weak self] _ in
            self?.tableView.scrollToTop(animated: true)
        })
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
    
    @IBAction func didSelectSegment(sender: UISegmentedControl) {
        vm.currentSection.value = ChatsViewModel.Section(rawValue: sender.selectedSegmentIndex)!
    }
}

extension ChatsViewController : DZNEmptyDataSetSource {
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let message: String
        switch vm.currentSection.value {
        case .Contacts:
            message = LS(.emptyContactsMessage)
        case .New:
            message = LS(.emptyNewMessage)
        }
        return NSAttributedString(string: message, attributes: [
            NSFontAttributeName: UIFont(.cabinRegular, size: 20)
        ])
    }
}
