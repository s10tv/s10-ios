//
//  AzureClient.swift
//  S10
//
//  Created by Tony Xiao on 8/3/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import CocoaLumberjack
import Alamofire
import ReactiveCocoa
import React

@objc(TSAzureClient)
class AzureClient : NSObject {
    
    let alamo: Manager
    
    override convenience init() {
        self.init(manager: Manager.sharedInstance)
    }
    
    init(manager: Manager) {
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

extension AzureClient {
    @objc func put(remoteURL: NSURL, localURL: NSURL, contentType: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        // For some reason if we use SignalProducer.promise here it breaks build...
        put(remoteURL, file: localURL, contentType: contentType).start(Event.sink(error: { error in
            reject(error)
            DDLogError("Unable to upload to azure", tag: error)
        }, completed: {
            resolve(nil)
            DDLogDebug("Successfully uploaded to azure")
        }))
    }
}