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
        vm.integrations.map { (vm, index) -> UICollectionViewCell in
            let cell = self.collectionView!.dequeueReusableCellWithReuseIdentifier("IntegrationCell", forIndexPath: NSIndexPath(forItem: index, inSection: 0)) as! IntegrationCell
            cell.bind(vm)
            return cell
        } ->> collectionView!
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: view.frame.width, height: 60)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? AuthWebViewController,
            let indexPath = collectionView?.indexPathsForSelectedItems().first as? NSIndexPath {
                let integration = vm.integrations[indexPath.item]
                vc.targetURL = integration.url
                vc.title = integration.title
        }
    }
}
