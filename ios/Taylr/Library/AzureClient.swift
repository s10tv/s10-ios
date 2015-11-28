//
//  AzureClient.swift
//  S10
//
//  Created by Tony Xiao on 8/3/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Alamofire
import ReactiveCocoa

class AzureClient {
    
    let alamo: Manager
    
    init(manager: Manager = Manager.sharedInstance) {
        alamo = manager
    }
    
    func put(url: NSURL, data: NSData, contentType: String) -> SignalProducer<NSData?, NSError> {
        let request = putRequestWithURL(url, contentType: contentType)
        return alamo.upload(request, data: data).validate().responseData()
    }
    
    func put(url: NSURL, file: NSURL, contentType: String) -> SignalProducer<NSData?, NSError> {
        let request = putRequestWithURL(url, contentType: contentType)
        return alamo.upload(request, file: file).validate().responseData()
    }
    
    private func putRequestWithURL(url: NSURL, contentType: String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "PUT"
        request.addValue("2014-02-14", forHTTPHeaderField: "x-ms-version")
        request.addValue("BlockBlob", forHTTPHeaderField: "x-ms-blob-type")
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        return request
    }
}