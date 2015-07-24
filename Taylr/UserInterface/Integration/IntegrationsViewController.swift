//
//  IntegrationsViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/24/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Bond
import Core
import Meteor

class IntegrationsViewController : UICollectionViewController {
    
    let vm = IntegrationListViewModel(meteor: Meteor)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vm.subscribe()
        let cells = vm.integrations.map { (vm, index) -> UICollectionViewCell in
            let cell = self.collectionView!.dequeueReusableCellWithReuseIdentifier("IntegrationCell", forIndexPath: NSIndexPath(forItem: index, inSection: 0)) as! IntegrationCell
            cell.bind(vm)
            return cell
        }
        cells ->> collectionView!
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: view.frame.width, height: 60)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        println("integrations \(vm.integrations.count)")
        let count = Meteor.collection("integrations").allDocuments.count
        println("integrations2 \(count)")
    }
}
