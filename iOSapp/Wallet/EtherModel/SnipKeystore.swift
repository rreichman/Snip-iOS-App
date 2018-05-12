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
import BigInt

enum WalletError: Error {
    case invalidRecoveryPhrase
}
public enum GasLimit {
    case eth
    case snip
}

extension KeyStore {
    func fuckYourShit() {
        
    }
}
class SnipKeystore {
    static let ETH_GAS_LIMIT: BigInt = BigInt(21000)
    static let TOKEN_GAS_LIMIT: BigInt = BigInt(144000)
    
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
        
        //self.deleteWalletFile()
        //self.keyStore = try! KeyStore(keyDirectory: keyDirectory)
    }
    // MARK: Debug
    func debugDeleteAll() {
        //keychain.clear()
        //deleteWalletFile()
        for account in keyStore.accounts {
            if let p = keychain.get(account.address.description) {
                do {
                    try keyStore.delete(account: account, password: p)
                    print("\(account.address.description) deleted")
                } catch {
                    //deleteWalletFile()
                    print("Deleting wallet file, we lost a password somehow")
                }
                
            }
        }
    }
    
    func deleteWalletFile() {
        let fm = FileManager.default
        do {
            try FileManager.default.removeItem(at: account!.url)
            
            try fm.removeItem(at: URL(fileURLWithPath: dataDir + keyFolder))
        } catch {
            print("Error deleting keystore file \(error)")
        }
        
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
    
    var hasWallet: Bool {
        if let a = self.address {
            return WalletUtils.validEthAddress(address: a.description)
        } else {
            return false
        }
    }
    
    func createWallet() -> Single<String> {
        let internalPassword = PasswordGen.generateRandomPassword()
        
        return Single<String>.create { single in
            do {
                let phrase = Mnemonic.generate(strength: 128)
                let account = try self.keyStore.import(mnemonic: phrase, passphrase: "", derivationPath: "m/0'", encryptPassword: internalPassword)
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
                let account = try self.keyStore.import(mnemonic: phrase, passphrase: "", derivationPath: "m/0'", encryptPassword: internalPassword)
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
    
    func makeTransaction (to address: String, gasData: GasData, gasLimit: GasLimit, amount: BigInt, nonce: Int, data: Data) throws -> SignTransaction {
        guard let account = self.account else {
            throw TransactionError.keystoreError(message: "Account not found")
        }
        var t: SignTransaction = SignTransaction(value: amount, account: account, to: Address.init(string: address), nonce: BigInt(nonce), data: data, gasPrice: gasData.priceInWei(for: gasData.userSelection), gasLimit: (gasLimit == .eth ? SnipKeystore.ETH_GAS_LIMIT : SnipKeystore.TOKEN_GAS_LIMIT), chainID: NetworkSettings.rinkeby.chain_id )
        return t
    }
    
    func generateRawTokenTransaction() {}
    
    func signTransaction(_ transaction: SignTransaction) throws -> (Data, String) {
        guard let account = self.account else {
            throw TransactionError.keystoreError(message: "Wallet was not found, try reimporting your wallet")
        }
        guard let password = getPassword(for: account) else {
            throw TransactionError.keystoreError(message: "Invalid wallet, try reimporting your wallet")
        }
        let signer: Signer
        if transaction.chainID == 0 {
            signer = HomesteadSigner()
        } else {
            signer = EIP155Signer(chainId: BigInt(transaction.chainID))
        }
        
        do {
            let hash = signer.hash(transaction: transaction)
            let signature = try keyStore.signHash(hash, account: account, password: password)
            let (r, s, v) = signer.values(transaction: transaction, signature: signature)
            let data = RLP.encode([
                transaction.nonce,
                transaction.gasPrice,
                transaction.gasLimit,
                transaction.to?.data ?? Data(),
                transaction.value,
                transaction.data,
                v, r, s,
                ])!
            let transactionID = WalletUtils.dataToHexString(data: rawHash(data))
            return (data, transactionID)
        } catch {
            throw TransactionError.generalErrorMessage(message: "Unable to sign transaction")
        }
    }

    
    @discardableResult
    func setPhrase(_ phrase: String, for account: Account) -> Bool {
        return keychain.set(phrase, forKey: account.address.description+"-phrase", withAccess: .accessibleWhenUnlockedThisDeviceOnly)
    }
    
    @discardableResult
    func setPassword(_ password: String, for account: Account) -> Bool{
        return keychain.set(password, forKey: account.address.description, withAccess: .accessibleWhenUnlockedThisDeviceOnly)
    }
    
    func getPassword(for account: Account) -> String? {
        return keychain.get(account.address.description)
    }
}
