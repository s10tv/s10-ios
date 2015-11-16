//
//  IntegrationsViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/24/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Meteor
import FBSDKLoginKit
import PKHUD
import Core

class IntegrationsViewController : UICollectionViewController {
    
    let vm = IntegrationListViewModel(MainContext)
    
    var selectedIntegration: IntegrationViewModel? {
        return (collectionView?.indexPathsForSelectedItems()?.first).flatMap {
            vm.integrations[$0.item]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get rid of warnings around initial item width too large
        updateLayoutItemSize()
        collectionView! <~ (vm.integrations, IntegrationCell.self)
    }
    
    override func viewWillLayoutSubviews() {
        updateLayoutItemSize()
        super.viewWillLayoutSubviews()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? IntegrationWebViewController {
            vc.integration = selectedIntegration
            vc.integrationDelegate = self
        }
    }
    
    // MARK: -
    
    func updateLayoutItemSize() {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: view.frame.width - layout.sectionInset.left - layout.sectionInset.right, height: 60)
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

extension IntegrationsViewController : ClientIntegrationDelegate {
    func linkClientSide(integrationId: String) -> Future<(), ErrorAlert>? {
        switch integrationId {
        case "facebook":
            return linkFacebook()
        default:
            return nil
        }
    }
    
    func linkFacebook() -> Future<(), ErrorAlert> {
        let promise = Promise<(), ErrorAlert>()
        let fb = FBSDKLoginManager()
        let readPerms = [
            "user_about_me",
            "user_photos",
            "user_location",
            "user_work_history",
            "user_education_history",
            "user_birthday",
            "user_posts",
            // TODO: What other permissions do we need here?
            // extended permissions
            "email"
        ]
        
        fb.logInWithReadPermissions(readPerms, fromViewController: nil) { result, error in
            // Todo: check result.grantedPermissions is complete
            if error != nil {
//                promise.failure(error)
                promise.failure(ErrorAlert(title: LS(.errUnableToAddServiceTitle),
                    message: LS(.errUnableToAddServiceMessage)))
            } else if result.isCancelled {
                promise.cancel() // TODO: Check whether or not this is actuallly correct behavior
            } else {
                Log.debug("Successfulled received token from facebook")
                dispatch_async(dispatch_get_main_queue()) {
                    PKHUD.showActivity()
                    promise.future.deliverOn(UIScheduler()).onComplete { _ in
                        PKHUD.hide(animated: false)
                    }
                    MainContext.meteor.addService("facebook", accessToken: result.token.tokenString).onSuccess {
                        promise.success()
                    }.onFailure { _ in
                        promise.failure(ErrorAlert(title: LS(.errUnableToAddServiceTitle),
                            message: LS(.errUnableToAddServiceMessage)))
                    }
                }
            }
        }
        return promise.future.deliverOn(UIScheduler())
    }
}