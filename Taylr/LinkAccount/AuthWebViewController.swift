//
//  AuthWebViewController.swift
//  S10
//
//  Created by Tony Xiao on 6/30/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation

class AuthWebViewController: UIViewController {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var webView: UIWebView!
    var targetURL: NSURL!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        webView.loadRequest(NSURLRequest(URL: targetURL))
        navBar.topItem?.title = title
    }
    
    @IBAction func cancelAuth(sender: AnyObject) {
        dismissViewController(animated: true)
    }
}

extension AuthWebViewController : UIWebViewDelegate {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let scheme = request.URL?.scheme where Globals.env.audience.urlScheme.hasPrefix(scheme) {
            self.dismissViewController(animated: true)
        }
        return true
    }
}
