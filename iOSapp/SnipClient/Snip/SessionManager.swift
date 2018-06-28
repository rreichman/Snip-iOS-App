//
//  SessionManager.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/18/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import KeychainSwift
import RxSwift

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
                print("authToken deleted")
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
                print("session deleted")
                userdefaults.removeObject(forKey: SessionManager.sessionCookieKey)
            }
            userdefaults.synchronize()
        }
    }
    
    func clearAll() {
        self.authToken = nil
        self.currentLoginName = nil
        self.currentLoginIntitals = nil
        self.currentLoginUsername = nil
    }
    
    func setLoginData(auth_token: String, user: User) {
        clearAll()
        self.authToken = auth_token
        
        let realm = RealmManager.instance.getRealm()
        try! realm.write {
            realm.add(user, update: true)
        }
        
        self.currentLoginUsername = user.username
        self.currentLoginName = "\(user.first_name) \(user.last_name)"
        self.currentLoginIntitals = user.initials
    }
    
    
    func logout() {
        // Delete user object in realm if it exists
        let realm = RealmManager.instance.getRealm()
        if let loggedInUserName = SessionManager.instance.currentLoginUsername,
            let loggedInUser = realm.object(ofType: User.self, forPrimaryKey: loggedInUserName) {
            try! realm.write {
                //if let avatarImage = loggedInUser.avatarImage {
                //    realm.delete(avatarImage)
                //}
                realm.delete(loggedInUser)
            }
        }
        
        clearAll()
        // Logging out invalidates the session cookie, but we don't want it to be cleared on login
        self.sessionCookie = nil
    }
    
    func setUserProfile(name: String, username: String, initials: String) {
        self.currentLoginUsername = username
        self.currentLoginIntitals = initials
        self.currentLoginName = name
    }
    
}
