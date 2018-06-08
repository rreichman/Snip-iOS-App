//
//  SessionManager.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/18/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import KeychainSwift

class SessionManager {
    
    public static let instance: SessionManager = SessionManager()
    
    static let currentLoginKey: String = "snipCurrentLogin"
    static let currentLoginName: String = "snipCurrentName"
    static let currentLoginInitials: String = "snipCurrentInitials"
    static let sessionCookieKey: String = "snipSessionCookie"
    static let authTokenKey: String = "snip-auth-token-"
    let keychain: KeychainSwift
    let userdefaults: UserDefaults
    init() {
        keychain = KeychainSwift(keyPrefix: "snip")
        userdefaults = UserDefaults.standard
    }
    
    var currentLoginUsername: String? {
        get {
            return userdefaults.string(forKey: SessionManager.currentLoginKey)
        }
        set {
            if let login = newValue {
                userdefaults.set(login, forKey: SessionManager.currentLoginKey)
                userdefaults.synchronize()
            } else {
                userdefaults.removeObject(forKey: SessionManager.currentLoginKey)
                userdefaults.synchronize()
            }
        }
    }
    var currentLoginName: String? {
        get {
            return userdefaults.string(forKey: SessionManager.currentLoginName)
        }
        set {
            if let login = newValue {
                userdefaults.set(login, forKey: SessionManager.currentLoginName)
                userdefaults.synchronize()
            } else {
                userdefaults.removeObject(forKey: SessionManager.currentLoginName)
                userdefaults.synchronize()
            }
        }
    }
    var currentLoginIntitals: String? {
        get {
            return userdefaults.string(forKey: SessionManager.currentLoginInitials)
        }
        set {
            if let login = newValue {
                userdefaults.set(login, forKey: SessionManager.currentLoginInitials)
                userdefaults.synchronize()
            } else {
                userdefaults.removeObject(forKey: SessionManager.currentLoginInitials)
                userdefaults.synchronize()
            }
        }
    }
    
    var authToken: String? {
        get {
            return keychain.get(SessionManager.authTokenKey)
        } set {
            if let token = newValue {
                keychain.set(token, forKey: SessionManager.authTokenKey)
            } else {
                keychain.delete(SessionManager.authTokenKey)
            }
        }
    }
    
    var loggedIn: Bool {
        if let _ = self.authToken {
            return true
        } else {
            return false
        }
    }
    
    var sessionCookie: String? {
        get {
            return  userdefaults.string(forKey: SessionManager.sessionCookieKey)
        } set {
            if let session = newValue {
                userdefaults.set(session, forKey: SessionManager.sessionCookieKey)
            } else {
                userdefaults.removeObject(forKey: SessionManager.sessionCookieKey)
            }
            userdefaults.synchronize()
        }
    }
    
    func oldAuthProxy(token: String) {
        self.authToken = token
        SnipRequests.instance.buildProfile(authToken: token)
        
    }
    func oldAuthProxyLogout() {
        self.authToken = nil
        self.currentLoginUsername = nil
        self.currentLoginName = nil
        self.currentLoginIntitals = nil
    }
    
}
