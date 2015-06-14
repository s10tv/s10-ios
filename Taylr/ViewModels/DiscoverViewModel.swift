//
//  DiscoverViewModel.swift
//  Taylr
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import CoreData

class DiscoverViewModel : NSObject {
    private let frc : NSFetchedResultsController
    weak var collectionView : UICollectionView?
    
    override init() {
        frc = Candidate.sorted(by: CandidateAttributes.score.rawValue, ascending: false).frc()
        super.init()
        frc.delegate = self
        frc.performFetch(nil)
    }
    
    func bindCollectionView(collectionView: UICollectionView) {
        self.collectionView = collectionView
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension DiscoverViewModel : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView?.reloadData()
    }
}

extension DiscoverViewModel : UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return frc.fetchedObjects?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CandidateCell", forIndexPath: indexPath) as! CandidateCell
        cell.candidate = frc.objectAtIndexPath(indexPath) as? Candidate
        return cell
    }
}

extension DiscoverViewModel : UICollectionViewDelegate {
    
}