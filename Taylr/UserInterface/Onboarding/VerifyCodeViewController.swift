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
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var introView: UIView!

    let vm = VerifyCodeViewModel(MainContext)

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        let url = NSURL("https://cas.id.ubc.ca/ubc-cas/login")
        let req = NSURLRequest(URL: url)
        webView.loadRequest(req)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @IBAction func didPressCWL(sender: AnyObject) {
        introView.hidden = true
//        self.performSegue(.RegisterEmailToConnectServices)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.track("View: JoinNetwork")
    }
}

extension VerifyCodeViewController : UIWebViewDelegate {
    func webViewDidFinishLoad(webView: UIWebView) {
        if let cookie = NSHTTPCookieStorage.sharedHTTPCookieStorage()
            .cookies?.filter({ $0.name == "CASTGC" }).first {
                vm.joinUBCNetwork(cookie.value).onSuccess {
                    Analytics.track("Network: JoinSuccess")
                    self.performSegue(.RegisterEmailToConnectServices)
                }.onFailure { error in
                    Analytics.track("Network: JoinError")
                    // Handle error actually...
                    self.performSegue(.RegisterEmailToConnectServices)
                }
        }
    }
}