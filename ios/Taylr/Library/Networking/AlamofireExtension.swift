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

// MARK: - ReactiveCocoa

public let kAlamofireResumeData = "resumeData"

extension Request {
    
    public func responseData() -> Future<NSData?, NSError> {
        let promise = Promise<NSData?, NSError>()
        response { urlRequest, urlResponse, value, error in
            if let e = error {
                var userInfo = e.userInfo ?? [:]
                userInfo[kAlamofireResumeData] = value
                promise.failure(NSError(domain: e.domain, code: e.code, userInfo: userInfo))
            } else {
                promise.success(value)
            }
        }
        return promise.future
    }
}
