//
//  NotificationManager.swift
//  iOSapp
//
//  Created by Carl Zeiger on 6/19/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit

import UserNotifications
import Firebase

class NotificationManager {
    static let instance: NotificationManager = NotificationManager()
    
    private let userdefaults: UserDefaults
    
    private let _firebaseRegistrationTokenKey: String = "firebaseRegistrationKey"
    var firebaseRegistrationToken: String? {
        get {
            return userdefaults.string(forKey: self._firebaseRegistrationTokenKey)
        }
        set {
            if let token = newValue {
                userdefaults.set(token, forKey: self._firebaseRegistrationTokenKey)
                userdefaults.synchronize()
            } else {
                userdefaults.removeObject(forKey: self._firebaseRegistrationTokenKey)
                userdefaults.synchronize()
            }
        }
    }
    
    private let _appLaunchCountKey: String = "appLaunchCountKey"
    var appLaunchCount: Int {
        get {
            return userdefaults.integer(forKey: self._appLaunchCountKey)
        }
        set {
            userdefaults.set(newValue, forKey: self._appLaunchCountKey)
            userdefaults.synchronize()
        }
    }
    
    private let _haveNotificationAccessKey: String = "haveNotificationAccessKey"
    var haveNotificationAccess: Bool {
        get {
            return userdefaults.bool(forKey: self._haveNotificationAccessKey)
        }
        set {
            userdefaults.set(newValue, forKey: self._haveNotificationAccessKey)
            userdefaults.synchronize()
        }
    }
    
    private let _userDidOptOutOfNotificationsKey: String = "userDidOptOutOfNotificationsKey"
    var userDidOptOutOfNotifications: Bool {
        get {
            return userdefaults.bool(forKey: self._userDidOptOutOfNotificationsKey)
        }
        set {
            userdefaults.set(newValue, forKey: self._userDidOptOutOfNotificationsKey)
            userdefaults.synchronize()
        }
    }
    
    private let _userDidDenyRequest: String = "userDidDenyRequest"
    var userDidDenyRequest: Bool {
        get {
            return userdefaults.bool(forKey: self._userDidDenyRequest)
        }
        set {
            userdefaults.set(newValue, forKey: self._userDidDenyRequest)
            userdefaults.synchronize()
        }
    }
    
    init() {
        userdefaults = UserDefaults.standard
    }
    
    func shouldShowNotificationRequest() -> Bool {
        return !self.haveNotificationAccess && self.appLaunchCount > 0 && !self.userDidOptOutOfNotifications && !self.userDidDenyRequest
    }
    
    func shouldShowNotificationSetting() -> Bool {
        return !self.haveNotificationAccess && !self.userDidDenyRequest
    }
    
    func userClosedNotificationBanner() {
        self.userDidOptOutOfNotifications = true
    }
    
    func showNotificationAccessRequest(completion: ((Bool) -> Void)? = nil) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {granted, error in
                print("Reuqested authorization from notification center")
                if let e = error {
                    print("Error requesting authorization \(e)")
                    completion?(false)
                    return
                }
                if granted {
                    print("Request granted, registering for notifications")
                    self.haveNotificationAccess = true
                    completion?(true)
                } else {
                    print("Request not granted")
                    self.haveNotificationAccess = false
                    self.userDidDenyRequest = true
                    //self.userDidOptOutOfNotifications = true
                    completion?(false)
                }
        })
    }
    
    func saveAndSendRegistrationToken(registrationToken: String) {
        self.firebaseRegistrationToken = registrationToken
        sendRegistrationToken(registrationToken: registrationToken)
    }
    
    func sendRegistrationTokenAfterLogin() {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                self.sendRegistrationToken(registrationToken: result.token)
            }
        }
    }
    
    private func sendRegistrationToken(registrationToken: String) {
        NotificationRequests.instance.sendFirebaseToken(registrationToken: registrationToken)
    }
}
