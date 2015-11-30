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
    static let fullname = DefaultsKey<String?>("ts_fullname")
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
    private(set) var fullname: String? {
        get { return ud[.fullname] }
        set { ud[.fullname] = newValue }
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
    }
    
    func appDidLaunch() {
        ud[.previousBuild] = env.build
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
        self.userId = nil
        self.resumeToken = nil
        self.tokenExpiry = nil
        self.username = nil
        self.phone = nil
        self.email = nil
        self.fullname = nil
        self.avatarURL = nil
        self.coverURL = nil
        ud.synchronize()
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
    
    @objc func setUserFullname(fullname: String?) {
        assert(loggedIn)
        self.fullname = fullname
        DDLogInfo("setUserFullName fullname=\(fullname)")
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
        json["tokenExpiry"] = tokenExpiry
        json["username"] = username
        json["email"] = email
        json["phone"] = phone
        json["fullname"] = fullname
        json["avatarURL"] = avatarURL
        json["coverURL"] = coverURL
        return ["initialValue": json]
    }
}