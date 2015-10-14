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

    let taskId: String
    let recipient: ConversationId
    let localURL: NSURL
    let thumbnailData: NSData
    let width: Int
    let height: Int
    let duration: NSTimeInterval
    let meteorService: MeteorService
    let azure = AzureClient()

    init(taskId: String,
        recipient: ConversationId,
        localURL: NSURL,
        thumbnailData: NSData,
        width: Int,
        height: Int,
        duration: NSTimeInterval,
        meteorService: MeteorService) {
        assert(localURL.fileURL, "Local video url must be fileURL")
        self.taskId = taskId
        self.recipient = recipient
        self.localURL = localURL
        self.thumbnailData = thumbnailData
        self.width = width
        self.height = height
        self.duration = duration
        self.meteorService = meteorService
    }

    override func run() {
        let info: [String: AnyObject] = [
            "duration": duration,
            "width": width,
            "height": height
        ]
        let prefix = "VideoUpload[\(taskId)]"
        Log.info("\(prefix) Will Start")
        var bgTaskId: UIBackgroundTaskIdentifier!
        bgTaskId = UIApplication.sharedApplication().beginBackgroundTaskWithName("VideoUpload[\(taskId)]") {
            Log.debug("\(prefix) Expired")
            UIApplication.sharedApplication().endBackgroundTask(bgTaskId)
        }
        meteorService.startMessageTask(taskId, recipient: recipient, info: info)
            .flatMap { res -> Future<(), NSError> in
                Log.debug("\(prefix) Will upload to videoURL \(res.videoURL) thumbnailURL \(res.thumbnailURL)")
                let thumb = self.azure.put(res.thumbnailURL, data: self.thumbnailData, contentType: "image/jpeg")
                let vid = self.azure.put(res.videoURL, file: self.localURL, contentType: "video/mp4")
                return zip(thumb.producer, vid.producer).map { _ in }.toFuture()
            }.flatMap { _ in
                Log.debug("\(prefix) Finished uploading video & thumbnail")
                return self.meteorService.finishTask(self.taskId)
            }.onFailure { error in
                Log.info("\(prefix) Failed with error \(error)")
                self.finish(.Error(error))
            }.onSuccess {
                let realm = unsafeNewRealm()
                if let task = VideoUploadTask.findByTaskId(self.taskId, realm: realm) {
                    realm.write {
                        realm.delete(task)
                    }
                    _ = try? NSFileManager().removeItemAtURL(self.localURL)
                }
                self.finish(.Success)
                Log.info("\(prefix) Finished Successfully")
                UIApplication.sharedApplication().endBackgroundTask(bgTaskId)
            }
    }
}