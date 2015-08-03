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

internal class InviteOperation : AsyncOperation {
    let taskType: String = "INVITE"

    let azure = AzureClient()
    let meteor: MeteorService
    let taskId: String
    let localVideoURL: NSURL
    let firstName: String
    let lastName: String
    let emailOrPhone: String
    let thumbnailData: NSData
    let videoWidth: Int
    let videoHeight: Int

    init(meteor: MeteorService, task: InviteTask) {
        self.meteor = meteor
        taskId = task.taskId
        localVideoURL = NSURL(task.localVideoUrl)
        firstName = task.firstName
        lastName = task.lastName
        emailOrPhone = task.emailOrPhone
        thumbnailData = task.thumbnailData
        videoWidth = task.videoWidth
        videoHeight = task.videoHeight
    }
    
    override func run() {
        let metadata = [
            "to": emailOrPhone,
            "firstName": firstName,
            "lastName": lastName,
            "videoWidth": videoWidth,
            "videoHeight": videoHeight
        ]
        
        meteor.startTask(taskId, type: taskType, metadata: metadata).toSignalProducer()
            |> toFuture
            // Valid startTask server response
            |> flatMap { res -> Future<(url: NSURL, thumbnailURL: NSURL), NSError> in
                if let json = res.map({ JSON($0) }),
                let url = json["url"].string.flatMap({ NSURL($0) }),
                let thumbnailURL = json["thumbnailUrl"].string.flatMap({ NSURL($0) }) {
                    return Future(value: (url, thumbnailURL))
                }
                return Future(error: NSError(domain: "Invite", code: 0, userInfo: [
                    NSLocalizedDescriptionKey: "Invalid Server Invite Task Response \(res)"
                ]))
            }
            // Upload video + thumbnail to azure
            |> flatMap { res -> Future<(), NSError> in
                let thumb = self.azure.put(res.thumbnailURL, data: self.thumbnailData, contentType: "image/jpeg")
                let vid = self.azure.put(res.url, file: self.localVideoURL, contentType: "video/mp4")
                return zip(thumb.producer, vid.producer)
                    |> map { _ in () }
                    |> toFuture
            }
            |> flatMap { () -> Future<(), NSError> in
                return self.meteor.finishTask(self.taskId)
                    .toSignalProducer() |> toFuture |> map { _ in () }
            }
            // Cleanup task
            |> onTerminate {
                // Unconditionally remove invite for now to avoid infinite retries
                // TODO: Make me offline capable
                let realm = Realm()
                if let task = InviteTask.findByTaskId(self.taskId, realm: realm) {
                    realm.write {
                        realm.delete(task)
                    }
                    NSFileManager().removeItemAtURL(self.localVideoURL, error: nil)
                } else {
                    Log.error("InviteTask complete but unable to find task with taskId=\(self.taskId)")
                }
                if let result = $0 {
                    switch result {
                    case .Success:
                        println("Succeeded invite task \(self.taskId)")
                        self.finish(.Success)
                    case .Failure(let e):
                        println("Failed invite task \(self.taskId) error \(e.value)")
                        self.finish(.Error(e.value))
                    }
                } else {
                    self.finish(.Cancelled)
                }
            }
    }
}

