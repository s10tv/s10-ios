//
//  HomeViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class HomeViewController : BaseViewController,
                           UITableViewDataSource,
                           UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "PostHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "PostHeader")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterViewWithIdentifier("PostHeader") as? UIView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! UITableViewCell
    }

}