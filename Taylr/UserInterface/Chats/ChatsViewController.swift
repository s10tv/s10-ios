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
        
        vm.connections.map { [unowned self] (vm, index) -> UITableViewCell in
            let cell = self.tableView.dequeueReusableCellWithIdentifier(.ContactConnectionCell,
                forIndexPath: NSIndexPath(forRow: index, inSection: 0)) as! ContactConnectionCell
            cell.bindViewModel(vm as! ContactConnectionViewModel)
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
    
    @IBAction func didSelectSegment(sender: UISegmentedControl) {
        vm.currentSection.value = ChatsViewModel.Section(rawValue: sender.selectedSegmentIndex)!
    }
}