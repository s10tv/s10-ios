//
//  InviteOperation.swift
//  S10
//
//  Created by Qiming Fang on 7/16/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Core
import SwiftyJSON
import ReactiveCocoa
import Alamofire

public class InviteOperation : AsyncOperation {
    let taskType: String = "INVITE"

    let meteor: MeteorService
    let localVideoURL: NSURL
    let recipientFirstName: String
    let recipientLastName: String
    let recipientPhoneOrEmail: String

    public init(meteor: MeteorService, localVideoURL: NSURL, recipientFirstName: String,
        recipientLastName: String, recipientPhoneOrEmail: String) {
            self.meteor = meteor
            self.localVideoURL = localVideoURL
            self.recipientFirstName = recipientFirstName
            self.recipientLastName = recipientLastName
            self.recipientPhoneOrEmail = recipientPhoneOrEmail
    }

    public override func run() {
        let taskId = NSUUID().UUIDString

        let metadata = [
            "to": self.recipientPhoneOrEmail,
            "firstName": self.recipientFirstName,
            "lastName": self.recipientLastName
        ]

        meteor.startTask(taskId, type: taskType, metadata: metadata).flattenMap {
            let url = JSON($0)["url"].string!
            let request = NSMutableURLRequest(URL: NSURL(string : url)!)
            request.HTTPMethod = "PUT"
            request.addValue("2014-02-14", forHTTPHeaderField: "x-ms-version")
            request.addValue("BlockBlob", forHTTPHeaderField: "x-ms-blob-type")
            request.addValue("video/mp4", forHTTPHeaderField: "Content-Type")
            return Alamofire.upload(request, self.localVideoURL).rac_statuscode()
        }.flattenMap {
            if let code = $0 as? Int where code >= 200 && code < 300 {
                return self.meteor.finishTask(taskId)
            }
            return RACSignal.error(NSError(domain: "Azure", code: $0 as! Int, userInfo: nil))
        }.subscribeError({
            self.finish(.Error($0))
        }, completed: {
            self.finish(.Success)
        })
    }
}

