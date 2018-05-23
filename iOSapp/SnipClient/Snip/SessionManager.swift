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
    static let sessionCookieKey: String = "snipSessionCookie"
    let keychain: KeychainSwift
    let userdefaults: UserDefaults
    init() {
        keychain = KeychainSwift(keyPrefix: "snip")
        userdefaults = UserDefaults.standard
    }
    
    
    private func getTokenKeyForUser(username: String) -> String {
            return "snip-auth-token-\(username)"
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
    
    var authToken: String? {
        get {
            guard let username = self.currentLoginUsername else { return nil }
            return keychain.get(getTokenKeyForUser(username: username))
        } set {
            guard let username = self.currentLoginUsername else { return }
            if let token = newValue {
                keychain.set(token, forKey: self.getTokenKeyForUser(username: username))
            } else {
                keychain.delete(getTokenKeyForUser(username: username))
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
    
}
