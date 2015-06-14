//
//  FeedViewModel.swift
//  Taylr
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import CoreData

class FeedViewModel : NSObject {
    private let frc : NSFetchedResultsController
    weak var tableView : UITableView?
    
    override init() {
        frc = Post.sorted(by: PostAttributes.score.rawValue, ascending: false).frc()
        super.init()
        frc.delegate = self
        frc.performFetch(nil)
    }
    
    func bindTableView(tableView: UITableView) {
        self.tableView = tableView
        tableView.registerNib(UINib(nibName: "PostHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "PostHeader")
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension FeedViewModel : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView?.reloadData()
    }
}

extension FeedViewModel : UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return frc.fetchedObjects?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier("PostHeader") as? PostHeaderView
        view?.post = frc.fetchedObjects?[section] as? Post
        return view
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostCell
        cell.post = frc.fetchedObjects?[indexPath.section] as? Post
        return cell
    }
}

extension FeedViewModel : UITableViewDelegate {
    
}