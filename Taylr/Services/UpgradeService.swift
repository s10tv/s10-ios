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
    
    init(env: TaylrEnvironment, settings: Settings) {
        promptAction = Action {
            SignalProducer { observer, disposable in
                let buildNumber = Int((env.build as NSString).intValue)
                let needsHardUpgrade = buildNumber < (settings.hardMinBuild.value ?? 0)
                let needsSoftUpgrade = buildNumber < (settings.softMinBuild.value ?? 0)
                let upgradeURL = settings.upgradeURL.value
                Log.debug("Might prompt upgrade build=\(buildNumber) hardMin=\(settings.hardMinBuild) softMin=\(settings.softMinBuild)")
                
                // Local builds produced by xcode, disable prompt
                if buildNumber == 0 && env.audience == .Dev {
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
            } |> startOn(UIScheduler())
        }
        combineLatest(
            settings.softMinBuild.producer |> skip(1),
            settings.hardMinBuild.producer |> skip(1)
        ).start(next: { [weak self] _ in
            self?.promptForUpgradeIfNeeded()
        })
    }
    
    func promptForUpgradeIfNeeded() {
        promptAction.apply().start()
    }
}