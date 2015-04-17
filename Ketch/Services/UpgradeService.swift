//
//  UpgradeService.swift
//  Ketch
//
//  Created by Tony Xiao on 4/15/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import Meteor
import ReactiveCocoa

class UpgradeService : NSObject {
    let env: Environment
    let meta: Metadata
    var buildNumber: Int {
        return Int((env.build as NSString).intValue)
    }
    var needsHardUpgrade: Bool {
        return buildNumber < (meta.hardMinBuild ?? 0)
    }
    var needsSoftUpgrade: Bool {
        return buildNumber < (meta.softMinBuild ?? 0)
    }
    // TODO: Need to figure out a better way to decide when is a bad time to prompt for upgrade
    var promptInProgress = false
    
    // MARK: -
    
    init(env: Environment, meta: Metadata) {
        self.env = env
        self.meta = meta
        super.init()
        NC.addObserver(self, selector: "databaseDidChange:", name: METDatabaseDidChangeNotification, object: nil)
    }
    
    func promptForUpgradeIfNeeded() {
        if (!NSThread.isMainThread()) {
            dispatch_async(dispatch_get_main_queue()) {
                self.promptForUpgradeIfNeeded()
            }
            return
        }
        
        Log.debug("Might prompt upgrade build=\(buildNumber) hardMin=\(meta.hardMinBuild) softMin=\(meta.softMinBuild)")
        if (!needsSoftUpgrade && !needsHardUpgrade) || promptInProgress {
            return
        }
        // Local builds produced by xcode, disable prompt
        if buildNumber == 0 && env.audience == .Dev {
            return
        }
        if let topVC = UIViewController.topMostViewController() {
            promptInProgress = true
            promptForUpgrade(topVC).subscribeCompleted {
                self.promptInProgress = false
            }
        } else {
            Log.error("Unable to find topMostViewController, skipping prompt for upgrade")
        }
    }
    
    private func promptForUpgrade(viewController: UIViewController) -> RACSignal {
        let subject = RACReplaySubject()
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .Alert)
        func performUpgrade(action: UIAlertAction!) {
            UIApplication.sharedApplication().openURL(env.upgradeURL)
            subject.sendCompleted()
        }
        if needsHardUpgrade {
            alert.title = LS(R.Strings.hardUpgradeAlertTitle)
            alert.message = LS(R.Strings.hardUpgradeAlertMessage)
            alert.addAction(LS(R.Strings.hardUpgradeAlertOk), handler: performUpgrade)
        } else if needsSoftUpgrade {
            alert.title = LS(R.Strings.softUpgradeAlertTitle)
            alert.message = LS(R.Strings.softUpgradeAlertMessage)
            alert.addAction(LS(R.Strings.softUpgradeAlertOk), handler: performUpgrade)
            alert.addAction(LS(R.Strings.softUpgradeAlertCancel), style: .Cancel) { _ in
                subject.sendCompleted()
            }
        }
        viewController.presentViewController(alert, animated: true)
        return subject
    }
    
    // MARK: -
    
    func databaseDidChange(notification: NSNotification) {
        if let changes = notification.userInfo?[METDatabaseChangesKey] as? METDatabaseChanges {
            let pairs = changes.affectedDocumentKeys().allObjects
                .map { $0 as METDocumentKey }
                .map { ($0.collectionName, $0.documentID as String) }
            for (name, key) in pairs {
                if name == "metadata" && (key == "softMinBuild" || key == "hardMinBuild") {
                    self.promptForUpgradeIfNeeded()
                    return
                }
            }
        }
    }
}