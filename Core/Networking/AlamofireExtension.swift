// AlamofireExtension.swift

import Foundation
import Alamofire
import ReactiveCocoa

public enum NSURLSessionType {
    case Default, Ephemeral, Background(String)
    public func sessionConfig() -> NSURLSessionConfiguration {
        switch self {
        case .Default: return NSURLSessionConfiguration.defaultSessionConfiguration()
        case .Ephemeral: return NSURLSessionConfiguration.ephemeralSessionConfiguration()
        case .Background(let id): return NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(id)
        }
    }
}

// MARK: - Convenience -

extension Manager {
    convenience public init(sessionType: NSURLSessionType = .Default, headers: [String:String] = Manager.defaultHTTPHeaders) {
        let config = sessionType.sessionConfig()
        config.HTTPAdditionalHeaders = headers
        self.init(configuration: config)
    }
}

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

// MARK: - BrightFutures

public let kAlamofireResumeData = "resumeData"

extension Request {
    
    public func responseData() -> Future<NSData?, NSError> {
        let promise = Promise<NSData?, NSError>()
        response { urlRequest, urlResponse, value, error in
            if let e = error {
                var userInfo = e.userInfo ?? [:]
                userInfo[kAlamofireResumeData] = value as? NSData
                promise.failure(NSError(domain: e.domain, code: e.code, userInfo: userInfo))
            } else {
                promise.success(value as? NSData)
            }
        }
        return promise.future
    }
}
