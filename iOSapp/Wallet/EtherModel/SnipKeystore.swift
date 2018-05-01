//
//  Keystore.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/1/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import KeychainSwift
import TrustCore
import TrustKeystore
import RxSwift

enum WalletError: Error {
    case invalidRecoveryPhrase
}

class SnipKeystore {
    
    static let walletAddressKey = "walletAddressKey"
    static let walletPhraseKey = "walletPhraseKey"
    static let keychainPrefix: String = "snipwallet"
    static let instance: SnipKeystore = SnipKeystore()
    
    let dataDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let keychain: KeychainSwift
    let keyFolder: String
    let keyDirectory: URL
    let userDefaults: UserDefaults
    let keyStore: KeyStore
    init(
        keychain: KeychainSwift = KeychainSwift(keyPrefix: keychainPrefix),
        keyFolder: String = "/keystore",
        userDefaults: UserDefaults = UserDefaults.standard
    ) {
        self.keychain = keychain
        self.keyFolder = keyFolder
        self.keyDirectory = URL(fileURLWithPath: dataDir + keyFolder)
        self.userDefaults = userDefaults
        self.keyStore = try! KeyStore(keyDirectory: keyDirectory)
    }
    
    var address: Address? {
        set {
            if let a = newValue {
                let data = a.data
                userDefaults.set(data, forKey: SnipKeystore.walletAddressKey)
                userDefaults.synchronize()
            }
        }
        get {
            guard let data = userDefaults.data(forKey: SnipKeystore.walletAddressKey) else { return nil }
            return Address(data: data)
        }
    }
    
    var account: Account? {
        if let adr = self.address {
            if let a = keyStore.account(for: adr) {
                return a
            }
        }
        return nil
    }
    
    func createWallet() -> Single<String> {
        let internalPassword = PasswordGen.generateRandomPassword()
        
        return Single<String>.create { single in
            do {
                let phrase = Mnemonic.generate(strength: 128)
                let account = try self.keyStore.import(mnemonic: phrase, passphrase: "", derivationPath: "m/1'", encryptPassword: internalPassword)
                self.setPassword(internalPassword, for: account)
                self.setPhrase(phrase, for: account)
                self.address = account.address
                single(SingleEvent<String>.success(phrase))
                
            } catch {
                single(.error(error))
            }
            return Disposables.create()
            }.subscribeOn(SerialDispatchQueueScheduler(qos: .default))
        
    }
    
    func importWallet(phrase: String) -> Single<Address> {
        let internalPassword = PasswordGen.generateRandomPassword()
        if !Mnemonic.isValid(phrase) {
            return Single<Address>.error(WalletError.invalidRecoveryPhrase)
        }
        return Single<Address>.create { single in
            do {
                let account = try self.keyStore.import(mnemonic: phrase, passphrase: "", derivationPath: "m/1'", encryptPassword: internalPassword)
                self.setPassword(internalPassword, for: account)
                self.setPhrase(phrase, for: account)
                self.address = account.address
                single(SingleEvent<Address>.success(account.address))
                
            } catch {
                single(.error(error))
            }
            return Disposables.create()
            }.subscribeOn(SerialDispatchQueueScheduler(qos: .default))
        
    }
    
    @discardableResult
    func setPhrase(_ phrase: String, for account: Account) {
        
    }
    
    @discardableResult
    func setPassword(_ password: String, for account: Account) -> Bool{
        return keychain.set(password, forKey: account.address.description, withAccess: .accessibleWhenUnlockedThisDeviceOnly)
    }
}
