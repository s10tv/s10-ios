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
    
    let meteorService: MeteorService
    let uploadQueue: NSOperationQueue
    var token: NotificationToken?

    public init(meteorService: MeteorService) {
        uploadQueue = NSOperationQueue()
        self.meteorService = meteorService
        NSFileManager.defaultManager().removeItemAtPath(Realm.defaultPath, error: nil)
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
    
    func queueOperation(operation: VideoUploadOperation) {
        operation.completionBlock = {
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                self?.resumeUploads()
            }
        }
        uploadQueue.addOperation(operation)
    }
}
