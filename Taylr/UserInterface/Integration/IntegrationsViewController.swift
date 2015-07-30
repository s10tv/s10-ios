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
        // Get rid of warnings around initial item width too large
        updateLayoutItemSize()
        vm.integrations.map(collectionView!.factory(IntegrationCell)) ->> collectionView!
    }
    
    override func viewWillLayoutSubviews() {
        updateLayoutItemSize()
        super.viewWillLayoutSubviews()
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == SegueIdentifier.IntegrationsToWeb.rawValue
            && linkClientSide(selectedIntegration?.id ?? "") {
            return false
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? IntegrationWebViewController {
            vc.integration = selectedIntegration
        }
    }
    
    // MARK: -
    
    func updateLayoutItemSize() {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: view.frame.width - layout.sectionInset.left - layout.sectionInset.right, height: 60)
    }

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
    
    // MARK: - App Delegate Hooks
    
    class func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    class func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        if FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url,
            sourceApplication: sourceApplication, annotation: annotation) {
                return true
        }
        return false
    }
}
