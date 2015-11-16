//
//  UpgradeService.swift
//  Taylr
//
//  Created by Tony Xiao on 4/15/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Core

class UpgradeService {
    let promptAction: Action<(), (), NoError>
    
    init(env: TaylrEnvironment, currentUser: CurrentUser) {
        promptAction = Action {
            SignalProducer { observer, disposable in
                let buildNumber = Int((env.build as NSString).intValue)
                let needsHardUpgrade = false //buildNumber < (currentUser.hardMinBuild.value ?? 0)
                let needsSoftUpgrade = false //buildNumber < (currentUser.softMinBuild.value ?? 0)
                let upgradeURL : NSURL? = NSURL() // currentUser.upgradeURL.value
//                Log.debug("Might prompt upgrade build=\(buildNumber) hardMin=\(currentUser.hardMinBuild) softMin=\(currentUser.softMinBuild)")
                
                // Local builds produced by xcode, disable prompt
                if env.audience == .Dev {
                    sendInterrupted(observer)
                    return
                }
                if !needsHardUpgrade && !needsSoftUpgrade || upgradeURL == nil {
                    sendInterrupted(observer)
                    return
                }
                
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .Alert)
                func performUpgrade(action: UIAlertAction!) {
                    UIApplication.sharedApplication().openURL(upgradeURL!)
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
                let vc = UIViewController.topMostViewController()!
                vc.presentViewController(alert, animated: true)
                disposable.addDisposable {
                    vc.dismissViewController()
                }
            }.startOn(UIScheduler())
        }
//        combineLatest(
//            currentUser.softMinBuild.producer.skip(1),
//            currentUser.hardMinBuild.producer.skip(1),
//            currentUser.upgradeURL.producer.skip(1)
//        ).startWithNext { [weak self] _ in
//            self?.promptForUpgradeIfNeeded()
//        }
    }
    
    func promptForUpgradeIfNeeded() {
        promptAction.apply().start()
    }
}