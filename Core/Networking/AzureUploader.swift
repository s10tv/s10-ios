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
import SwiftyJSON

public final class AzureUploader {

    let meteorService : MeteorService!

    public init(meteorService : MeteorService) {
        self.meteorService = meteorService
    }

    /**
     * Uploads @param data to Azure shared access url @param url
     */
    public func uploadFile(connectionId: String, localUrl: NSURL) -> RACSignal {
        let taskId = NSUUID().UUIDString
        return meteorService.startTask(taskId, type: "MESSAGE",
                metadata: ["connectionId" : connectionId]).flattenMap { res in
            let videoUrl = JSON(res)["videoUrl"].string!
            let request = NSMutableURLRequest(URL: NSURL(string : videoUrl)!)
            request.HTTPMethod = "PUT"
            request.addValue("2014-02-14", forHTTPHeaderField: "x-ms-version")
            request.addValue("BlockBlob", forHTTPHeaderField: "x-ms-blob-type")
            request.addValue("text/plain", forHTTPHeaderField: "Content-Type")

            return Alamofire.upload(request, localUrl).rac_statuscode()
        }.then {
            return self.meteorService.finishTask(taskId)
        }
    }
}