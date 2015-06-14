//
//  DiscoverViewController.swift
//  Taylr
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation

class DiscoverViewController : BaseViewController {
    
    @IBOutlet weak var collectionView : UICollectionView!
    var discoverVM : DiscoverViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        discoverVM = DiscoverViewModel()
        discoverVM.bindCollectionView(collectionView)
    }

}