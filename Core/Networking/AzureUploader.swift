//
//  Uploader.swift
//  S10
//
//  Created by Qiming Fang on 6/17/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Alamofire
import Foundation
import ReactiveCocoa

public final class AzureUploader {

    public init() {}

    /**
     * Uploads @param data to Azure shared access url @param url
     */
    public func upload(url: String, data: NSData) -> RACSignal {
        let request = NSMutableURLRequest(URL: NSURL(string : url)!)
        request.HTTPMethod = "PUT"
        request.addValue("2014-02-14", forHTTPHeaderField: "x-ms-version")
        request.addValue("BlockBlob", forHTTPHeaderField: "x-ms-blob-type")
        request.addValue("text/plain", forHTTPHeaderField: "Content-Type")

        return Alamofire.upload(request, data).rac_statuscode()
    }
}