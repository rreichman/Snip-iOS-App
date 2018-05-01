//
//  PinLock.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/2/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import KeychainSwift

class PinLock {
    static let instance: PinLock = PinLock()
    static let keychainPrefix: String = "snipwallet"
    static let pinCodeKey = "pinCodeKey"
    
    let keychain: KeychainSwift
    init() {
        self.keychain = KeychainSwift(keyPrefix: PinLock.keychainPrefix)
        
    }
    
    var pinCode: String  {
        get {
            if let p = keychain.get(PinLock.pinCodeKey) {
                return p
            }
            return ""
        }
        set {
            keychain.set(newValue, forKey: PinLock.pinCodeKey)
        }
    }
    
    
    
}
