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
    }

    public func sendVideoMessage(connection: Connection, localVideoURL: NSURL,
            onNotificationFn: () -> Void) {
        let operation = VideoUploadOperation(
                connectionId: connection.documentID!,
                localVideoURL: localVideoURL,
                meteorService: self.meteorService,
                onNotificationFn: onNotificationFn)
        self.uploadQueue.addOperation(operation)
    }
}
