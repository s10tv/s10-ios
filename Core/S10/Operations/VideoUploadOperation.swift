//
//  VideoUploadOperation.swift
//  S10
//
//  Created by Qiming Fang on 6/20/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Alamofire
import Meteor
import RealmSwift
import SwiftyJSON
import ReactiveCocoa

internal class VideoUploadOperation : AsyncOperation {

    var taskId: String?
    let recipientId: String
    let localVideo: Video
    let meteorService: MeteorService
    let azure: AzureClient

    init(recipientId: String,
            localVideo: Video,
            meteorService: MeteorService) {
        assert(localVideo.url.fileURL, "Local video url must be fileURL")
        self.recipientId = recipientId
        self.localVideo = localVideo
        self.meteorService = meteorService
        self.azure = AzureClient()
    }

    override func run() {
        let realm = unsafeNewRealm()
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
        
        meteorService.startTask(taskId!,
            type: "MESSAGE",
            metadata: ["userId": self.recipientId, "duration": self.localVideo.duration ?? 0]
        ).flatMap { res -> Future<NSData?, NSError> in
            let url = NSURL(string: JSON(res!)["videoUrl"].string!)!
            return self.azure.put(url, file: self.localVideo.url, contentType: "video/mp4")
        }.flatMap { _ in
            return self.meteorService.finishTask(self.taskId!)
        }.onFailure { error in
            self.finish(.Error(error))
        }.onSuccess {
            let realm = unsafeNewRealm()
            realm.write {
                realm.delete(realm.objects(VideoUploadTask).filter(
                    NSPredicate(format: "id = %@", self.taskId!)))
            }
            self.finish(.Success)
        }
    }
}