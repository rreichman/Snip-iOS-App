//
//  Keystore.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/1/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import KeychainSwift

class Keystore {
    static let keychainPrefix: String = "snipwallet"
    static let instance: Keystore = Keystore()
    
    let keychain: KeychainSwift
    let keyFolder: String
    let userDefaults: UserDefaults
    init(
        keychain: KeychainSwift = KeychainSwift(keyPrefix: keychainPrefix),
        keyFolder: String = "/keystore",
        userDefaults: UserDefaults = UserDefaults.standard
    ) {
        self.keychain = keychain
        self.keyFolder = keyFolder
        self.userDefaults = userDefaults
    }
}
