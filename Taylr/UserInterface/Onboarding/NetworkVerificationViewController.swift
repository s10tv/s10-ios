//
//  NetworkVerificationViewController.swift
//  S10
//
//  Created by Tony Xiao on 10/20/15.
//  Copyright © 2015 S10. All rights reserved.
//

import UIKit

class NetworkVerificationViewController : UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL("https://cas.id.ubc.ca/ubc-cas/login")
        let req = NSURLRequest(URL: url)
        webView.loadRequest(req)
        
        webView.delegate = self
    }
}

extension NetworkVerificationViewController : UIWebViewDelegate {
    func webViewDidFinishLoad(webView: UIWebView) {
        if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies {
            for cookie in cookies {
                print("Got cookie \(cookie.name) details \(cookie)")
                if cookie.name == "CASTGC" {
                    let value = cookie.value
                    print("Successfully logged into UBC \(value)")
                    showAlert("Login Success", message: "YAY")
                }
            }
        }
    }
}
