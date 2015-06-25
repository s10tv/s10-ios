//
//  VideoUploadOperation.swift
//  S10
//
//  Created by Qiming Fang on 6/20/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Alamofire
import Core
import Foundation
import Meteor
import RealmSwift
import SwiftyJSON

public class VideoUploadOperation : AsyncOperation {

    let connectionId: String
    let localVideoURL: NSURL
    let meteorService: MeteorService

    public init(
            connectionId: String,
            localVideoURL: NSURL,
            meteorService: MeteorService) {
        self.connectionId = connectionId
        self.localVideoURL = localVideoURL
        self.meteorService = meteorService
    }

    override public func run() {
        let realm = Realm()
        let predicate = NSPredicate(format: "localURL = %@", localVideoURL.path!)
        let results = realm.objects(VideoUploadTaskEntry).filter(predicate)

        var taskId: String?
        switch (results.count) {
        case 0:
            taskId = NSUUID().UUIDString

            let entry = VideoUploadTaskEntry()
            entry.id = taskId!
            entry.localURL = localVideoURL.path!
            entry.connectionId = connectionId

            realm.write {
                realm.add(entry)
            }
            break
        case 1:
            taskId = results.first!.id
            break
        default:
            NSException(name: "Exception", reason: "Multiple localVideoURL", userInfo: nil).raise()
        }

        meteorService.startTask(taskId!, type: "MESSAGE",
                metadata: ["connectionId": self.connectionId]).flattenMap { res in
            let videoUrl = JSON(res)["videoUrl"].string!
            let request = NSMutableURLRequest(URL: NSURL(string : videoUrl)!)
            request.HTTPMethod = "PUT"
            request.addValue("2014-02-14", forHTTPHeaderField: "x-ms-version")
            request.addValue("BlockBlob", forHTTPHeaderField: "x-ms-blob-type")
            request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
            return Alamofire.upload(request, self.localVideoURL).rac_statuscode()
        }.flattenMap { res in
            let statusCode = res as! Int
            if (statusCode < 200 || statusCode >= 300) {
                return RACSignal.error(
                    NSError(domain: "Upload to Azure", code: statusCode, userInfo: nil))
            } else {
                return self.meteorService.finishTask(taskId!)
            }
        }.subscribeError({ (error) -> Void in
            self.finish(.Error(error))
        }, completed: { () -> Void in
            let realm = Realm()
            realm.write {
                realm.delete(realm.objects(VideoUploadTaskEntry).filter(
                    NSPredicate(format: "id = %@", taskId!)))
            }
            self.finish(.Success)
        })
    }
}