//
//  Session.swift
//  Taylr
//
//  Created by Tony Xiao on 11/29/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import CocoaLumberjack
import SwiftyUserDefaults
import React

extension DefaultsKeys {
    static let previousBuild = DefaultsKey<String?>("ts_previousBuild")
    static let userId = DefaultsKey<String?>("ts_userId")
    static let resumeToken = DefaultsKey<String?>("ts_resumeToken")
    static let tokenExpiry = DefaultsKey<NSDate?>("ts_tokenExpiry")
    static let username = DefaultsKey<String?>("ts_username")
    static let email = DefaultsKey<String?>("ts_email")
    static let phone = DefaultsKey<String?>("ts_phone")
    static let firstName = DefaultsKey<String?>("ts_firstName")
    static let lastName = DefaultsKey<String?>("ts_lastName")
    static let fullname = DefaultsKey<String?>("ts_fullname")
    static let displayName = DefaultsKey<String?>("ts_displayName")
    static let avatarURL = DefaultsKey<NSURL?>("ts_avatarURL")
    static let coverURL = DefaultsKey<NSURL?>("ts_coverURL")
}

@objc(TSSession)
class Session : NSObject {
    weak var bridge: RCTBridge?
    private(set) var userId: String? {
        get { return ud[.userId] }
        set { set(.userId, newValue) }
    }
    private(set) var resumeToken: String? {
        get { return ud[.resumeToken] }
        set { set(.resumeToken, newValue) }
    }
    private(set) var tokenExpiry: NSDate? {
        get { return ud[.tokenExpiry] }
        set { set(.tokenExpiry, newValue) }
    }
    
    var loggedIn: Bool {
        assert((userId == nil) == (resumeToken == nil), "userId and resumeToken out of sync")
        return userId != nil
    }
    let ud: NSUserDefaults
    let env: Environment
    let previousBuild: String?
    
    override convenience init() {
        self.init(userDefaults: Defaults, env: Environment())
    }
    
    private func set<T>(key: DefaultsKey<T>, _ value: Any?) {
        // Consider adding assertion for trying to set session attr when user is not logged in yet
        DDLogDebug("Will update session \(key._key)=\(value)")
        ud[key._key] = value
    }
    
    init(userDefaults: NSUserDefaults = Defaults, env: Environment = Environment()) {
        self.ud = userDefaults
        self.env = env
        if let previousBuild = ud[.previousBuild] {
            self.previousBuild = previousBuild
        } else if let account = METAccount.defaultAccount() {
            // HACK ALERT: Migration special case
            // pre ReactNative builds did not persist previousBuild into UserDefaults
            // We use METAccount as a proxy to know whether this was an upgrade rather than new install
            previousBuild = "0.2.1"
            ud[.userId] = account.userID
            ud[.resumeToken] = account.resumeToken
            ud[.tokenExpiry] = account.expiryDate
            METAccount.setDefaultAccount(nil)
        } else {
            previousBuild = nil
        }
        super.init()
        if (userId == nil) != (resumeToken == nil) {
            DDLogError("userId and resumeToken not in sync userId=\(userId) resumeToken=\(resumeToken)")
            reset()
        }
    }
    
    func appDidLaunch() {
        ud[.previousBuild] = env.build
        DDLogInfo("appDidLaunch userId=\(userId) previousBuild=\(previousBuild) currentBuildId=\(env.build)")
    }
    
    func reset() {
        DDLogInfo("Will reset NSUserDefaults.standardUserDefaults(). Will also remove value persisted outside Session")
        ud.removePersistentDomainForName(env.appId)
        ud[.previousBuild] = env.build
        ud.synchronize()
    }
}

// MARK: - JavaScript API

extension Session {
    @objc var username: String? {
        get { return ud[.username] }
        set { set(.username, newValue) }
    }
    @objc var email: String? {
        get { return ud[.email] }
        set { set(.email, newValue) }
    }
    @objc var phone: String? {
        get { return ud[.phone] }
        set { set(.phone, newValue) }
    }
    @objc var firstName: String? {
        get { return ud[.firstName] }
        set { set(.firstName, newValue) }
    }
    @objc var lastName: String? {
        get { return ud[.lastName] }
        set { set(.lastName, newValue) }
    }
    @objc var fullname: String? {
        get { return ud[.fullname] }
        set { set(.fullname, newValue) }
    }
    @objc var displayName: String? {
        get { return ud[.displayName] }
        set { set(.displayName, newValue) }
    }
    @objc var avatarURL: NSURL? {
        get { return ud[.avatarURL] }
        set { set(.avatarURL, newValue) }
    }
    @objc var coverURL: NSURL? {
        get { return ud[.coverURL] }
        set { set(.coverURL, newValue) }
    }
    
    @objc func login(userId: String, resumeToken: String, tokenExpiry: NSDate?) {
        assert(!loggedIn, "Must be logged out before login")
        self.userId = userId
        self.resumeToken = resumeToken
        self.tokenExpiry = tokenExpiry
        ud.synchronize()
        DDLogInfo("login userId=\(userId) resumeToken=\(resumeToken) tokenExpiry=\(tokenExpiry)")
    }
    
    @objc func logout() {
        assert(loggedIn, "Must be loggedIn before logout")
        reset()
        DDLogInfo("logout")
    }
    
    @objc func constantsToExport() -> [NSObject: AnyObject] {
        var json: [String: AnyObject] = [:]
        json["userId"] = userId
        json["resumeToken"] = resumeToken
        json["tokenExpiry"] = RCTConvert.jsonNSDate(tokenExpiry)
        json["username"] = username
        json["email"] = email
        json["phone"] = phone
        json["firstName"] = firstName
        json["lastName"] = lastName
        json["fullname"] = fullname
        json["displayName"] = displayName
        json["avatarURL"] = RCTConvert.jsonNSURL(avatarURL)
        json["coverURL"] = RCTConvert.jsonNSURL(coverURL)
        DDLogInfo("Will export constants initialValue=\(json)")
        return ["initialValue": json]
    }
}

extension RCTConvert {

    class func jsonNSDate(date: Foundation.NSDate?) -> String? {
        struct Static {
            static let formatter: NSDateFormatter = {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
                formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                formatter.timeZone = Foundation.NSTimeZone(name: "UTC")
                return formatter
            }()
        }
        return date.map { Static.formatter.stringFromDate($0) }
    }
    
    class func jsonNSURL(url: Foundation.NSURL?) -> String? {
        return url?.absoluteString
    }
}