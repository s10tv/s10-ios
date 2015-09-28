//
//  IntegrationWebViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/24/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import ReactiveCocoa
import PKHUD
import Core

protocol ClientIntegrationDelegate {
    func linkClientSide(integrationId: String) -> Future<(), ErrorAlert>?
}

class IntegrationWebViewController: UIViewController {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var webView: UIWebView!
    
    var integration: IntegrationViewModel!
    var integrationDelegate: ClientIntegrationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.scrollView.delegate = self
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Globals.analyticsService.track("Selected Integration", properties: [
            "integration" : integration.name])
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        webView.loadRequest(NSURLRequest(URL: integration.url))
        navBar.topItem?.title = integration.name
    }
    
    @IBAction func cancelAuth(sender: AnyObject) {
        dismissViewController(animated: true)
    }
    
    func tryLinkClientSide(integrationId: String) -> Bool {
        if let future = integrationDelegate?.linkClientSide(integrationId) {
            wrapFuture(showProgress: true) { future }.onSuccess {
                self.dismissViewController(animated: true)
            }
            return true
        }
        return false
    }
}

extension IntegrationWebViewController : UIWebViewDelegate {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let path = request.URL?.path where path.hasPrefix("/facebook/auth") {
            // Workaround for http://stackoverflow.com/questions/1840355/uiwebview-shouldstartloadwithrequest-only-called-once
            if let r = webView.request { webView.loadRequest(r) }
            return tryLinkClientSide("facebook") == false
        }
        if let scheme = request.URL?.scheme where Globals.env.audience.urlScheme.hasPrefix(scheme) {
            dismissViewController(animated: true)
        }
        return true
    }
}

extension IntegrationWebViewController : UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return nil
    }
}