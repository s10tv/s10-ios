//
//  AzureClient.swift
//  Serendipity
//
//  Created by Qiming Fang on 2/5/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class AzureClient {
    
    func getSasURL(callback: ((String?, String?) -> Void)) {
        let urlRequest = NSMutableURLRequest(URL: NSURL(string: "https://s10mobile.azure-mobile.net/api/uploadvideosas")!)
        urlRequest.HTTPMethod = "GET"
        urlRequest.addValue("NeHOImEPLUWXFdRmGmTWjRzoEbElSF33", forHTTPHeaderField: "X-ZUMO-APPLICATION")
        urlRequest.addValue("12345", forHTTPHeaderField: "userid")
        Alamofire.request(urlRequest).responseJSON {(_, _, data, error) in
            if let jsonData = data as? NSDictionary {
                let json = JSON(jsonData)
                return callback(json["sasUrl"].string, json["blobid"].string)
            }
            
            return callback(nil, nil)
        }
    }
    
    func uploadVideo(videoPath : String, callback: ((String?, NSError?) -> Void)) {
        getSasURL { url, blobid in
            if let sasUrl = url {
                let filePath = NSURL.fileURLWithPath(videoPath)
                
                let urlRequest = NSMutableURLRequest(URL: NSURL(string: sasUrl)!)
                urlRequest.HTTPMethod = "PUT"
                urlRequest.addValue("2012-02-12", forHTTPHeaderField: "x-ms-version")
                urlRequest.addValue("BlockBlob", forHTTPHeaderField: "x-ms-blob-type")
                Alamofire.upload(urlRequest, filePath!)
                    .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                        print(".")
                    }
                    .responseJSON {(request, response, data, error) in
                        return callback(blobid, error)
                    }
            }
        }
    }
}