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

    public init(meteorService: MeteorService) {
        self.meteorService = meteorService
        nc.listen(METIncrementalStoreObjectsDidChangeNotification) { [weak self] _ in
            for message in Message.all().fetch().map({ $0 as! Message }) {
                if message.status == .Sent {
                    self?.downloadVideo(message)
                }
            }
        }
    }
    
    // MARK: - Uploads
    
    func uploadVideo(recipient: User, localVideoURL: NSURL) {
        let operation = VideoUploadOperation(
            recipientId: recipient.documentID!,
            localVideoURL: localVideoURL,
            meteorService: self.meteorService)
        uploadQueue.addAsyncOperation(operation).onComplete { [weak self] _ in
            self?.resumeUploads()
        }
    }
    
    public func resumeUploads() {
        let queuedTaskIds = Set(uploadQueue.operations
            .map { $0 as! VideoUploadOperation }
            .filter { $0.taskId != nil }
            .map { $0.taskId! }
        )
        for task in Realm().objects(VideoUploadTask) {
            if queuedTaskIds.contains(task.id) {
                continue
            }
            let operation = VideoUploadOperation(
                recipientId: task.recipientId,
                localVideoURL: NSURL(task.localURL),
                meteorService: meteorService)
            operation.taskId = task.id
            uploadQueue.addAsyncOperation(operation).onComplete { [weak self] _ in
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
            let realm = Realm()
            realm.write {
                let task = VideoDownloadTask()
                task.videoId = videoId
                task.senderId = senderId
                task.remoteUrl = remoteUrl.absoluteString!
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
        for task in Realm().objects(VideoDownloadTask) {
            if queuedVideoIds.contains(task.videoId) {
                continue
            }
            downloadQueue.addAsyncOperation(VideoDownloadOperation(task: task))
                .onComplete { [weak self] _ in
                    self?.resumeDownloads()
                }
        }
    }
    
    // MARK: - Invites
    
    public func invite(emailOrPhone: String, localVideoURL: NSURL, firstName: String?, lastName: String?) -> Future<(), NSError> {
        let promise = Promise<(), NSError>()
        let realm = Realm()
        realm.write {
            let task = InviteTask()
            task.taskId = NSUUID().UUIDString
            task.emailOrPhone = emailOrPhone
            task.localVideoUrl = localVideoURL.absoluteString!
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
        for task in Realm().objects(InviteTask) {
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
