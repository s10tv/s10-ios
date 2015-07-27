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
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    let vm: ChatsViewModel = ChatsViewModel(meteor: Meteor)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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