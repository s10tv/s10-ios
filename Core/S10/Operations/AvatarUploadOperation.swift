//
//  AvatarUploadOperation.swift
//  S10
//
//  Created by Tony Xiao on 7/3/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Core
import SwiftyJSON
import Alamofire

public class AvatarUploadOperation : AsyncOperation {
    let meteor: MeteorService
    let image: UIImage
    
    public init(meteor: MeteorService, image: UIImage) {
        self.meteor = meteor
        self.image = image
    }
    
    public override func run() {
        let imageData = UIImageJPEGRepresentation(image, 0.8)
        let taskId = NSUUID().UUIDString
        meteor.startTask(taskId, type: "PROFILE_PIC", metadata: [:]).flattenMap {
            let url = JSON($0)["url"].string!
            let request = NSMutableURLRequest(URL: NSURL(string : url)!)
            request.HTTPMethod = "PUT"
            request.addValue("2014-02-14", forHTTPHeaderField: "x-ms-version")
            request.addValue("BlockBlob", forHTTPHeaderField: "x-ms-blob-type")
            request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")
            return Alamofire.upload(request, imageData).rac_statuscode()
        }.flattenMap {
            if let code = $0 as? Int where code >= 200 && code < 300 {
                return self.meteor.finishTask(taskId)
            }
            return RACSignal.error(NSError(domain: "Azure", code: $0 as! Int, userInfo: nil))
        }.subscribeError({
            self.finish(.Error($0))
        }, completed: {
            self.finish(.Success)
        })
    }
}
