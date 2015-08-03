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
import ReactiveCocoa

internal class VideoUploadOperation : AsyncOperation {

    var taskId: String?
    let recipientId: String
    let localVideo: Video
    let meteorService: MeteorService

    init(recipientId: String,
            localVideo: Video,
            meteorService: MeteorService) {
        assert(localVideo.url.fileURL, "Local video url must be fileURL")
        self.recipientId = recipientId
        self.localVideo = localVideo
        self.meteorService = meteorService
    }

    override func run() {
        let realm = Realm()
        let predicate = NSPredicate(format: "localURL = %@", localVideo.url.path!)
        let results = realm.objects(VideoUploadTask).filter(predicate)
        
        switch (results.count) {
        case 0:
            taskId = NSUUID().UUIDString

            let entry = VideoUploadTask()
            entry.id = taskId!
            entry.localURL = localVideo.url.path!
            entry.recipientId = recipientId
            entry.duration = localVideo.duration ?? 0

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
                metadata: ["userId": self.recipientId, "duration": self.localVideo.duration ?? 0]).flattenMap { res in
            let videoUrl = JSON(res)["videoUrl"].string!
            let request = NSMutableURLRequest(URL: NSURL(string : videoUrl)!)
            request.HTTPMethod = "PUT"
            request.addValue("2014-02-14", forHTTPHeaderField: "x-ms-version")
            request.addValue("BlockBlob", forHTTPHeaderField: "x-ms-blob-type")
            request.addValue("video/mp4", forHTTPHeaderField: "Content-Type")
            return Alamofire.upload(request, file: self.localVideo.url).rac_statuscode()
        }.flattenMap { res in
            let statusCode = res as! Int
            if (statusCode < 200 || statusCode >= 300) {
                return RACSignal.error(
                    NSError(domain: "Upload to Azure", code: statusCode, userInfo: nil))
            } else {
                return self.meteorService.finishTask(self.taskId!)
            }
        }.subscribeError({ (error) -> Void in
            self.finish(.Error(error))
        }, completed: { () -> Void in
            let realm = Realm()
            realm.write {
                realm.delete(realm.objects(VideoUploadTask).filter(
                    NSPredicate(format: "id = %@", self.taskId!)))
            }
            self.finish(.Success)
        })
    }
}