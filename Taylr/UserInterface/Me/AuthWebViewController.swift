//
//  AuthWebViewController.swift
//  S10
//
//  Created by Tony Xiao on 6/30/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import OAuthSwift

class AuthWebViewController: UIViewController {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var webView: UIWebView!
    var targetURL: NSURL!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.loadRequest(NSURLRequest(URL: targetURL))
    }
    
    @IBAction func cancelAuth(sender: AnyObject) {
        dismissViewController(animated: true)
    }
}

extension AuthWebViewController : OAuthSwiftURLHandlerType {
    func handle(url: NSURL) {
        targetURL = url
        let rootVC = UIApplication.sharedApplication().keyWindow?.rootViewController
        rootVC?.presentViewController(self, animated: true, completion: nil)
    }
}

extension AuthWebViewController : UIWebViewDelegate {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url = request.URL where url.scheme == Globals.env.audience.urlScheme {
            self.dismissViewController(animated: true)
        }
        return true
    }
}
