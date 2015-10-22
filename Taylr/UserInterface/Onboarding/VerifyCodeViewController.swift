//
//  VerifyCodeViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/30/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Core

class VerifyCodeViewController : UIViewController {
    @IBOutlet var nextBarButtonItem: UIBarButtonItem!
    @IBOutlet var webView: UIWebView!
    @IBOutlet var introView: UIView!

    let vm = VerifyCodeViewModel(MainContext)

    override func viewDidLoad() {
        super.viewDidLoad()
        clearCWLCookie()
        let casRequest = NSURLRequest(URL: NSURL("https://cas.id.ubc.ca/ubc-cas/login"))
        webView.delegate = self
        webView.loadRequest(casRequest)
        navigationItem.rightBarButtonItem = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @IBAction func didPressCWL(sender: AnyObject) {
        UIView.transitionFromView(introView, toView: webView, duration: 1,
            options: [.TransitionCurlUp], completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.track("View: JoinNetwork")
    }
}

extension VerifyCodeViewController : UIWebViewDelegate {
    
    func findCWLCookie() -> NSHTTPCookie? {
        return NSHTTPCookieStorage.sharedHTTPCookieStorage()
            .cookies?.filter({ $0.name == "CASTGC" }).first
    }
    
    func clearCWLCookie() {
        let jar = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if let cookie = findCWLCookie() {
            jar.deleteCookie(cookie)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if let cookie = findCWLCookie() {
            vm.joinUBCNetwork(cookie.value).onSuccess {
                Analytics.track("Network: JoinSuccess")
                self.performSegue(.JoinNetworkToConnectServices)
                self.navigationItem.rightBarButtonItem = self.nextBarButtonItem
            }.onFailure { error in
                Analytics.track("Network: JoinError")
                // Handle error actually...
                self.performSegue(.JoinNetworkToConnectServices)
            }
        }
    }
}