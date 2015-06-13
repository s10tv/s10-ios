//
//  ChatsViewModel.swift
//  Ketch
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import CoreData

class ChatsViewModel : NSObject {
    private let frc : NSFetchedResultsController
    weak var tableView : UITableView?
    
    override init() {
        frc = Connection.sorted(by: ConnectionAttributes.updatedAt.rawValue, ascending: false).frc()
        super.init()
        frc.delegate = self
        frc.performFetch(nil)
    }
    
    func bindTableView(tableView: UITableView) {
        self.tableView = tableView
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension ChatsViewModel : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView?.reloadData()
    }
}

extension ChatsViewModel : UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frc.fetchedObjects?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ConnectionCell", forIndexPath: indexPath) as! ConnectionCell
        cell.connection = frc.fetchedObjects?[indexPath.section] as? Connection
        return cell
    }
}

extension ChatsViewModel : UITableViewDelegate {
    
}