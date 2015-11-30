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
        set { ud[.userId] = newValue }
    }
    private(set) var resumeToken: String? {
        get { return ud[.resumeToken] }
        set { ud[.resumeToken] = newValue }
    }
    private(set) var tokenExpiry: NSDate? {
        get { return ud[.tokenExpiry] }
        set { ud[.tokenExpiry] = newValue }
    }
    private(set) var username: String? {
        get { return ud[.username] }
        set { ud[.username] = newValue }
    }
    private(set) var email: String? {
        get { return ud[.email] }
        set { ud[.email] = newValue }
    }
    private(set) var phone: String? {
        get { return ud[.phone] }
        set { ud[.phone] = newValue }
    }
    private(set) var firstName: String? {
        get { return ud[.firstName] }
        set { ud[.firstName] = newValue }
    }
    private(set) var lastName: String? {
        get { return ud[.lastName] }
        set { ud[.lastName] = newValue }
    }
    private(set) var fullname: String? {
        get { return ud[.fullname] }
        set { ud[.fullname] = newValue }
    }
    private(set) var displayName: String? {
        get { return ud[.displayName] }
        set { ud[.displayName] = newValue }
    }
    private(set) var avatarURL: NSURL? {
        get { return ud[.avatarURL] }
        set { ud[.avatarURL] = newValue }
    }
    private(set) var coverURL: NSURL? {
        get { return ud[.coverURL] }
        set { ud[.coverURL] = newValue }
    }
    var loggedIn: Bool {
        assert((userId == nil) == (resumeToken == nil), "userId and resumeToken out of sync")
        return userId != nil
    }
    let ud: NSUserDefaults
    let env: Environment
    let previousBuild: String?
    
    init(userDefaults: NSUserDefaults, env: Environment) {
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
        DDLogInfo("Will reset")
        self.userId = nil
        self.resumeToken = nil
        self.tokenExpiry = nil
        self.username = nil
        self.phone = nil
        self.email = nil
        self.firstName = nil
        self.lastName = nil
        self.fullname = nil
        self.displayName = nil
        self.avatarURL = nil
        self.coverURL = nil
        ud.synchronize()
    }
}

// MARK: - JavaScript API

extension Session {
    
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
    // TODO: See if we can combine with property declaration above
    @objc func setUserUsername(username: String?) {
        assert(loggedIn)
        self.username = username
        DDLogInfo("setUserUsername username=\(username)")
    }
    
    @objc func setUserPhone(phone: String?) {
        assert(loggedIn)
        self.phone = phone
        DDLogInfo("setUserPhone phone=\(phone)")
    }
    
    @objc func setUserEmail(email: String?) {
        assert(loggedIn)
        self.email = email
        DDLogInfo("setUserEmail email=\(email)")
    }
    
    @objc func setUserFirstName(firstName: String?) {
        assert(loggedIn)
        self.firstName = firstName
        DDLogInfo("setUserFirstName firstName=\(firstName)")
    }
    
    @objc func setUserLastName(lastName: String?) {
        assert(loggedIn)
        self.lastName = lastName
        DDLogInfo("setUserLastName lastName=\(lastName)")
    }

    @objc func setUserFullname(fullname: String?) {
        assert(loggedIn)
        self.fullname = fullname
        DDLogInfo("setUserFullName fullname=\(fullname)")
    }

    @objc func setUserDisplayName(displayName: String?) {
        assert(loggedIn)
        self.displayName = displayName
        DDLogInfo("setUserDisplayName displayName=\(displayName)")
    }

    @objc func setUserAvatarURL(avatarURL: NSURL?) {
        assert(loggedIn)
        self.avatarURL = avatarURL
        DDLogInfo("setUserAvatarURL avatarURL=\(avatarURL)")
    }
    
    @objc func setUserCoverURL(coverURL: NSURL?) {
        assert(loggedIn)
        self.coverURL = coverURL
        DDLogInfo("setUserCoverURL coverURL=\(coverURL)")
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