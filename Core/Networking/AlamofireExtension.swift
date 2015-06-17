// AlamofireExtension.swift

import Foundation
import Alamofire
import ReactiveCocoa

// MARK: - Convenience -

private func URLRequest(method: Alamofire.Method, URL: URLStringConvertible) -> NSURLRequest {
    let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: URL.URLString)!)
    mutableURLRequest.HTTPMethod = method.rawValue

    return mutableURLRequest
}

// MARK: - ReactiveCocoa

extension Request {
    public func rac_statuscode() -> RACSignal {
        return RACSignal.createSignal({ subscriber in
            self.response({ (request, response, body, error) -> Void in
                if(error == nil) {
                    subscriber.sendNext(response?.statusCode)
                    subscriber.sendCompleted()
                } else {
                    subscriber.sendError(error)
                }
            })
            return nil
        })
    }
}