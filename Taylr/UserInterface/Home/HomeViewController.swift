//
//  HomeViewController.swift
//  Taylr
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation

class HomeViewController : BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var feedVM: FeedViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedVM = FeedViewModel()
        feedVM.bindTableView(tableView)
    }
}