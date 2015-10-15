//
//  ConnectServicesViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/30/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Core

class ConnectServicesViewController : UITableViewController {
    
    @IBOutlet weak var descriptionCell: UITableViewCell!
    @IBOutlet weak var integrationsCell: UITableViewCell!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var integrationsContainer: UIView!
    var integrationsVC: IntegrationsViewController!
    
    let vm = ConnectServicesViewModel(MainContext)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        integrationsVC = storyboard.instantiateViewControllerWithIdentifier("Integrations")
            as! IntegrationsViewController
        addChildViewController(integrationsVC)
        integrationsContainer.addSubview(integrationsVC.view)
        integrationsVC.view.makeEdgesEqualTo(integrationsContainer)
        integrationsVC.didMoveToParentViewController(self)

        integrationsVC.view.cornerRadius = 3
        integrationsVC.collectionView!.dyn("contentSize").force(NSValue).producer
            .skip(1)
            .skipRepeats()
            .observeOn(QueueScheduler.mainQueueScheduler)
            .startWithNext { _ in
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.track("View: ConnectServices")
    }
    
    @IBAction func didTapNext(sender: AnyObject) {
        wrapFuture {
            vm.finish()
        }.onSuccess {
            self.performSegue(.ConnectServicesToCreateProfile)
        }
    }
}

extension ConnectServicesViewController /* : UITableViewDelegate */ {

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // NOTE: Margins are hardcoded here. careful
        if indexPath.row == 0 {
            promptLabel.preferredMaxLayoutWidth = tableView.bounds.width - 16
            return promptLabel.intrinsicContentSize().height + 50
        } else {
            let layout = integrationsVC.collectionView!.collectionViewLayout
            return layout.collectionViewContentSize().height + 16
        }
    }
}