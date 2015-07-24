//
//  ServicesViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/22/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Bond
import Core

class ServicesViewController : UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cells = DynamicArray([1,2,3,4,5]).map { (_, index) -> UICollectionViewCell in
            let cell = self.collectionView!.dequeueReusableCellWithReuseIdentifier("ServiceCell", forIndexPath: NSIndexPath(forItem: index, inSection: 0)) as! UICollectionViewCell
            return cell
        }
        cells ->> collectionView!
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: view.frame.width, height: 60)
    }
}