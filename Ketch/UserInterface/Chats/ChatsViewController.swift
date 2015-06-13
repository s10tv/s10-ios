//
//  ChatsViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class ChatsViewController : BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var chatsVM : ChatsViewModel!
    
    override func viewDidLoad() {
        chatsVM = ChatsViewModel()
        chatsVM.bindTableView(tableView)
    }

}