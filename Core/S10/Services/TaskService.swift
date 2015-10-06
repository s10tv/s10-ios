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

public class TaskService {
    
    let nc = NSNotificationCenter.defaultCenter().proxy()
    let uploadQueue = NSOperationQueue()
    let downloadQueue = NSOperationQueue()
    let inviteQueue = NSOperationQueue()
    let meteorService: MeteorService
    
    // BIG TODO: Figure out how to cache & expire videos

    public init(meteorService: MeteorService) {
        self.meteorService = meteorService
        nc.listen(METIncrementalStoreObjectsDidChangeNotification) { [weak self] _ in
            for message in Message.all().fetch().map({ $0 as! Message }) {
                self?.downloadVideo(message)
            }
        }
    }
    
    // MARK: - Uploads
    
    func uploadVideo(recipient: ConversationId, localVideo: Video) {
        let realm = unsafeNewRealm()
        realm.write {
            let task = VideoUploadTask()
            task.taskId = NSUUID().UUIDString
            switch recipient {
            case .ConnectionId(let connectionId):
                task.connectionId = connectionId
            case .UserId(let userId):
                task.userId = userId
            }
            task.localVideoUrl = localVideo.url.absoluteString
            task.duration = localVideo.duration ?? 0
            task.thumbnailData = UIImageJPEGRepresentation(localVideo.thumbnail!.image!, 0.8)!
            task.width = localVideo.thumbnail?.width ?? 0
            task.height = localVideo.thumbnail?.height ?? 0
            realm.add(task)
        }
        resumeUploads()
    }
    
    public func resumeUploads() {
        let queuedTaskIds = Set(uploadQueue.operations.map {
            ($0 as! VideoUploadOperation).taskId
        })
        for task in unsafeNewRealm().objects(VideoUploadTask) {
            if queuedTaskIds.contains(task.taskId) {
                continue
            }
            let recipient: ConversationId = task.connectionId.length > 0
                ? .ConnectionId(task.connectionId)
                : .UserId(task.userId)
            uploadQueue.addAsyncOperation(
                VideoUploadOperation(
                    taskId: task.taskId,
                    recipient: recipient,
                    localURL: NSURL(string: task.localVideoUrl)!,
                    thumbnailData: task.thumbnailData,
                    width: task.width,
                    height: task.height,
                    duration: task.duration,
                    meteorService: meteorService
                )
            ).onComplete { [weak self] _ in
                self?.resumeUploads()
            }
        }
    }

    // MARK: - Downloads
    
    func downloadVideo(message: Message) {
        if let videoId = message.documentID,
            let senderId = message.sender.documentID,
            let remoteUrl = message.video.url {
            if VideoCache.sharedInstance.hasVideo(videoId) {
                return
            }
            let realm = unsafeNewRealm()
            realm.write {
                let task = VideoDownloadTask()
                task.videoId = videoId
                task.senderId = senderId
                task.remoteUrl = remoteUrl.absoluteString
                realm.add(task, update: true)
            }
            resumeDownloads()
        }
    }
    
    public func resumeDownloads() {
        let queuedVideoIds = Set(downloadQueue.operations
            .map { $0 as! VideoDownloadOperation }
            .map { $0.videoId }
        )
        for task in unsafeNewRealm().objects(VideoDownloadTask) {
            if queuedVideoIds.contains(task.videoId) {
                continue
            }
            downloadQueue.addAsyncOperation(
                VideoDownloadOperation(task: task)
            ).onComplete { [weak self] _ in
                self?.resumeDownloads()
            }
        }
    }
    
    // MARK: - Invites
    
    public func invite(emailOrPhone: String, localVideoURL: NSURL, thumbnail: UIImage, firstName: String?, lastName: String?) -> Future<(), NSError> {
        let promise = Promise<(), NSError>()
        let realm = unsafeNewRealm()
        realm.write {
            let task = InviteTask()
            task.taskId = NSUUID().UUIDString
            print("Will start invite task with id \(task.taskId)")
            task.emailOrPhone = emailOrPhone
            task.localVideoUrl = localVideoURL.absoluteString
            task.thumbnailData = UIImageJPEGRepresentation(thumbnail, 0.8)!
            // NOTE: Is it correct to use video width & height instead of thumb?
            task.videoWidth = Int(thumbnail.size.width * thumbnail.scale)
            task.videoHeight = Int(thumbnail.size.height * thumbnail.scale)
            task.firstName = firstName ?? ""
            task.lastName = lastName ?? ""
            realm.add(task, update: true)
            self.inviteQueue.addAsyncOperation {
                InviteOperation(meteor: self.meteorService, task: task)
            }.onSuccess {
                promise.success()
            }.onFailure {
                promise.failure($0)
            }.onComplete { _ in
                self.resumeInvites()
            }
        }
        return promise.future
    }
    
    public func resumeInvites() {
        let queuedTaskIds = Set(inviteQueue.operations
            .map { $0 as! InviteOperation }
            .map { $0.taskId }
        )
        for task in unsafeNewRealm().objects(InviteTask) {
            if queuedTaskIds.contains(task.taskId) {
                continue
            }
            inviteQueue.addAsyncOperation {
                InviteOperation(meteor: self.meteorService, task: task)
            }.onComplete { [weak self] _ in
                self?.resumeInvites()
            }
        }
    }
    
}
