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
    
    let fetch : FetchViewModel = FetchViewModel(frc: nil)
    var connection: Connection? {
        didSet {
            if isViewLoaded() { reloadData() }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: How to stop using hard-coded cellNibNames
        fetch.bindToCollectionView(self.view as UICollectionView, cellNibName: "MessageCell")
        fetch.collectionViewProvider?.configureCollectionCell = { item, cell in
            (cell as MessageCell).message = (item as Message)
        }
        fetch.collectionViewProvider?.didSelectItem = { item in
            println("Will play message \(item)")
        }
        reloadData()
    }
    
    func reloadData() {
        if let conn = connection {
            fetch.frc = Message.MR_fetchAllSortedBy(MessageAttributes.timestamp.rawValue, ascending: true,
                withPredicate: NSPredicate(format: "%K == %@", MessageRelationships.connection.rawValue, conn),
                groupBy: nil, delegate: nil)
        } else {
            println("Connection being nil is not yet handled. Not refreshing view for now")
        }
    }
    
}
