//  VideoUploaderService.swift
//  S10
//
//  Created by Qiming Fang on 6/20/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Alamofire
import Foundation
import RealmSwift
import ReactiveCocoa
import SwiftyJSON

public class VideoService {
    
    let uploadQueue = NSOperationQueue()
    let downloadQueue = NSOperationQueue()
    let meteorService: MeteorService
    var token: NotificationToken?

    public init(meteorService: MeteorService) {
        self.meteorService = meteorService
    }
    
    public func resumeDownloads() {
        let queuedVideoIds = Set(downloadQueue.operations
            .map { $0 as! VideoDownloadOperation }
            .map { $0.videoId }
        )
        for task in Realm().objects(VideoDownloadTaskEntry) {
            if queuedVideoIds.contains(task.videoId) {
                continue
            }
            perform {
                downloadQueue.addAsyncOperation(VideoDownloadOperation(task: task))
            }.onComplete { [weak self] _ in
                self?.resumeDownloads()
            }
        }
    }
    
    public func resumeUploads() {
        let queuedTaskIds = Set(uploadQueue.operations
            .map { $0 as! VideoUploadOperation }
            .filter { $0.taskId != nil }
            .map { $0.taskId! }
        )
        for task in Realm().objects(VideoUploadTaskEntry) {
            if queuedTaskIds.contains(task.id) {
                continue
            }
            let operation = VideoUploadOperation(
                recipientId: task.recipientId,
                localVideoURL: NSURL(task.localURL),
                meteorService: meteorService)
            operation.taskId = task.id
            queueOperation(operation)
        }
    }

    public func sendVideoMessage(recipient: User, localVideoURL: NSURL) {
        let operation = VideoUploadOperation(
                recipientId: recipient.documentID!,
                localVideoURL: localVideoURL,
                meteorService: self.meteorService)
        queueOperation(operation)
    }
    
    public func downloadVideo(video: Video) {
        if let videoId = video.documentID,
            let senderId = video.message?.sender?.documentID,
            let remoteUrl = video.url {
            let realm = Realm()
            realm.write {
                let task = VideoDownloadTaskEntry()
                task.videoId = videoId
                task.senderId = senderId
                task.remoteUrl = remoteUrl
                realm.add(task, update: true)
            }
            resumeDownloads()
        }
    }
    
    func queueOperation(operation: VideoUploadOperation) {
        operation.completionBlock = {
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                self?.resumeUploads()
            }
        }
        uploadQueue.addOperation(operation)
    }
}
