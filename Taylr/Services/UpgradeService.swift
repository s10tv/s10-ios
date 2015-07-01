//
//  UpgradeService.swift
//  Taylr
//
//  Created by Tony Xiao on 4/15/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import Meteor
import ReactiveCocoa
import Core

class UpgradeService : NSObject {
    let env: TaylrEnvironment
    let settings: Settings
    var buildNumber: Int {
        return Int((env.build as NSString).intValue)
    }
    var needsHardUpgrade: Bool {
        return buildNumber < (settings.hardMinBuild ?? 0)
    }
    var needsSoftUpgrade: Bool {
        return buildNumber < (settings.softMinBuild ?? 0)
    }
    // TODO: Need to figure out a better way to decide when is a bad time to prompt for upgrade
    var promptInProgress = false
    
    // MARK: -
    
    init(env: TaylrEnvironment, settings: Settings) {
        self.env = env
        self.settings = settings
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
        
        Log.debug("Might prompt upgrade build=\(buildNumber) hardMin=\(settings.hardMinBuild) softMin=\(settings.softMinBuild)")
        if (!needsSoftUpgrade && !needsHardUpgrade) || promptInProgress {
            return
        }
        // Local builds produced by xcode, disable prompt
        if buildNumber == 0 && env.audience == .Dev {
            return
        }
        if let topVC = UIViewController.topMostViewController() {
            promptInProgress = true
            promptForUpgrade(topVC).observe(completed: {
                self.promptInProgress = false
            }, interrupted: {
                self.promptInProgress = false
            })
        } else {
            Log.error("Unable to find topMostViewController, skipping prompt for upgrade")
        }
    }
    
    private func promptForUpgrade(viewController: UIViewController) -> Signal<Void, NoError> {
        let (signal, observer) = Signal<Void, NoError>.pipe()
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .Alert)
        func performUpgrade(action: UIAlertAction!) {
            UIApplication.sharedApplication().openURL(env.upgradeURL)
            sendCompleted(observer)
        }
        if needsHardUpgrade {
            alert.title = LS(.hardUpgradeAlertTitle)
            alert.message = LS(.hardUpgradeAlertMessage)
            alert.addAction(LS(.hardUpgradeAlertOk), handler: performUpgrade)
        } else if needsSoftUpgrade {
            alert.title = LS(.softUpgradeAlertTitle)
            alert.message = LS(.softUpgradeAlertMessage)
            alert.addAction(LS(.softUpgradeAlertOk), handler: performUpgrade)
            alert.addAction(LS(.softUpgradeAlertCancel), style: .Cancel) { _ in
                sendCompleted(observer)
            }
        }
        viewController.presentViewController(alert, animated: true)
        return signal
    }
    
    // MARK: -
    
    func databaseDidChange(notification: NSNotification) {
        if let changes = notification.userInfo?[METDatabaseChangesKey] as? METDatabaseChanges {
            let pairs = Array(changes.affectedDocumentKeys())
                .map { $0 as! METDocumentKey }
                .map { ($0.collectionName, $0.documentID as! String) }
            for (name, key) in pairs {
                if name == "metadata" && (key == "softMinBuild" || key == "hardMinBuild") {
                    self.promptForUpgradeIfNeeded()
                    return
                }
            }
        }
    }
}