//
//  IntegrationsViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/24/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Bond
import Meteor
import FBSDKLoginKit
import Async
import PKHUD
import Core

class IntegrationsViewController : UICollectionViewController {
    
    let vm = IntegrationListViewModel(meteor: Meteor)
    
    var selectedIntegration: IntegrationViewModel? {
        return (collectionView?.indexPathsForSelectedItems().first as? NSIndexPath).flatMap {
            vm.integrations[$0.item]
        }
    }
    
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
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == SegueIdentifier.IntegrationsToWeb.rawValue
            && linkClientSide(selectedIntegration?.id ?? "") {
            return false
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? AuthWebViewController,
            let integration = selectedIntegration {
                vc.targetURL = integration.url
                vc.title = integration.title
        }
    }
    
    // MARK: -

    func linkClientSide(integrationId: String) -> Bool {
        var signal: RACSignal?
        switch integrationId {
        case "facebook":
            signal = linkFacebook()
        default:
            return false
        }
        signal?.subscribeNext({ _ in
            PKHUD.showActivity()
        }, error: { error in
            PKHUD.hide(animated: false)
            self.showAlert(LS(.errUnableToAddServiceTitle), message: LS(.errUnableToAddServiceMessage))
        }, completed: {
            PKHUD.hide(animated: false)
        })
        return true
    }
    
    func linkFacebook() -> RACSignal {
        let subject = RACReplaySubject()
        let fb = FBSDKLoginManager()
        let readPerms = [
            "user_about_me",
            "user_photos",
            "user_location",
            "user_work_history",
            "user_education_history",
            "user_birthday",
            "user_posts",
            // extended permissions
            "email"
        ]
        fb.logInWithReadPermissions(readPerms) { result, error in
            // Todo: check result.grantedPermissions is complete
            if error != nil {
                subject.sendError(error)
            } else if result.isCancelled {
                subject.sendError(nil) // TODO: Send explicit error
            } else {
                subject.sendNext(nil) // TODO: Used to signal progress, make more explicit
                Log.debug("Successfulled received token from facebook")
                Async.main {
                    Meteor.addService("facebook", accessToken: result.token.tokenString).subscribe(subject)
                }
            }
        }
        return subject.deliverOnMainThread()
    }
}