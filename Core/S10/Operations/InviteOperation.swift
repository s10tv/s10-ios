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
import RealmSwift

public class InviteOperation : AsyncOperation {
    let taskType: String = "INVITE"

    let meteor: MeteorService
    let taskId: String
    let localVideoURL: NSURL
    let firstName: String
    let lastName: String
    let emailOrPhone: String

    public init(meteor: MeteorService, task: InviteTask) {
        self.meteor = meteor
        taskId = task.taskId
        localVideoURL = NSURL(task.localVideoUrl)
        firstName = task.firstName
        lastName = task.lastName
        emailOrPhone = task.emailOrPhone
    }
    
    public override func run() {
        let metadata = [
            "to": emailOrPhone,
            "firstName": firstName,
            "lastName": lastName
        ]

        meteor.startTask(taskId, type: taskType, metadata: metadata).flattenMap {
            let url = JSON($0)["url"].string!
            let request = NSMutableURLRequest(URL: NSURL(string : url)!)
            request.HTTPMethod = "PUT"
            request.addValue("2014-02-14", forHTTPHeaderField: "x-ms-version")
            request.addValue("BlockBlob", forHTTPHeaderField: "x-ms-blob-type")
            request.addValue("video/mp4", forHTTPHeaderField: "Content-Type")
            return Alamofire.upload(request, file: self.localVideoURL).rac_statuscode()
        }.flattenMap {
            if let code = $0 as? Int where code >= 200 && code < 300 {
                return self.meteor.finishTask(self.taskId)
            }
            return RACSignal.error(NSError(domain: "Azure", code: $0 as! Int, userInfo: nil))
        }.subscribeError({
            self.finish(.Error($0))
        }, completed: {
            let realm = Realm()
            if let task = InviteTask.findByTaskId(self.taskId, realm: realm) {
                realm.write {
                    realm.delete(task)
                }
                NSFileManager().removeItemAtURL(self.localVideoURL, error: nil)
            } else {
                Log.error("InviteTask complete but unable to find task with taskId=\(self.taskId)")
            }
            self.finish(.Success)
        })
    }
}

