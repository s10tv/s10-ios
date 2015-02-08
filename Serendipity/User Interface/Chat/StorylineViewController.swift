//
//  StorylineViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit

@objc(StorylineViewController)
class StorylineViewController : BaseViewController {
    
    var fetch : FetchViewModel?
    var connection: Connection? {
        didSet {
            if isViewLoaded() { reloadData() }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadData()
    }
    
    func reloadData() {
        // TODO: Changing connection after first reload might not work...
        if let conn = connection {
            let frc = Message.MR_fetchAllSortedBy(MessageAttributes.timestamp.rawValue, ascending: true,
                withPredicate: NSPredicate(format: "%K == %@", MessageRelationships.connection.rawValue, conn),
                groupBy: nil, delegate: nil)
            // TODO: How to stop using hard-coded cellNibNames
            fetch = FetchViewModel(frc: frc)
            fetch!.bindToCollectionView(self.view as UICollectionView, cellNibName: "MessageCell")
            fetch!.collectionViewProvider?.configureCollectionCell = { item, cell in
                (cell as MessageCell).message = (item as Message)
            }
            fetch!.collectionViewProvider?.didSelectItem = { item in
                println("Will play message \(item)")
            }
        } else {
            println("Connection being nil is not yet handled. Not refreshing view for now")
        }
    }
    
}
