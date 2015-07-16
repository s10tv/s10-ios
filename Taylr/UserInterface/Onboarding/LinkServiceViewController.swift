//
//  LinkServiceViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/15/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit

class LinkServiceViewController : UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Fix for tableview layout http://stackoverflow.com/questions/18880341/why-is-there-extra-padding-at-the-top-of-my-uitableview-with-style-uitableviewst
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0.01))
    }
}