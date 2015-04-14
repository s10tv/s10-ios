//
//  HomeViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 4/13/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import CoreData

class HomeViewController : BaseViewController {

    @IBOutlet var navViews: [UIView]!
    @IBOutlet weak var dockBadge: UIImageView!
    let unreadConnections = Connection.unread().frc()

    override func viewDidLoad() {
        super.viewDidLoad()
        unreadConnections.delegate = self
        unreadConnections.fetchObjects()
        controllerDidChangeContent(unreadConnections) // Force view update
    }
    
    override func handleScreenEdgePan(edge: UIRectEdge) -> Bool {
        Log.debug("Handding to edge \(edge) from gameVC")
        if edge == .Right {
            performSegue(.HomeToDock)
            return true
        }
        return super.handleScreenEdgePan(edge)
    }
    
    // MARK: - Actions
    
    @IBAction func unwindToHome(sender: UIStoryboardSegue) {
    }
    
}

extension HomeViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        dockBadge.hidden = controller.fetchedObjects?.count == 0
    }
}