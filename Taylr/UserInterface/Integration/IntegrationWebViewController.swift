//
//  IntegrationWebViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/24/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import Core

class IntegrationWebViewController: UIViewController {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var webView: UIWebView!
    
    var integration: IntegrationViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.scrollView.scrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        webView.loadRequest(NSURLRequest(URL: integration.url))
        navBar.topItem?.title = integration.title
    }
    
    @IBAction func cancelAuth(sender: AnyObject) {
        dismissViewController(animated: true)
    }
}

extension IntegrationWebViewController : UIWebViewDelegate {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let scheme = request.URL?.scheme where Globals.env.audience.urlScheme.hasPrefix(scheme) {
            self.dismissViewController(animated: true)
        }
        return true
    }
}

extension IntegrationWebViewController : UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return nil
    }
}