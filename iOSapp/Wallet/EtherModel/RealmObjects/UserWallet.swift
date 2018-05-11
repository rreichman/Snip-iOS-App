//
//  UserWallet.swift
//  iOSapp
//
//  Created by CJ Zeiger on 5/4/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import RealmSwift
import BigInt
import TrustCore

@objcMembers
class UserWallet: Object {

    let transactions = List<Transaction>()
    dynamic var address: String = ""
    dynamic var eth_balance_string: String = "0"
    dynamic var snip_balance_string: String = "0"
    dynamic var local_nonce: Int = 0
    
    override static func primaryKey() -> String? {
        return "address"
    }
    
    var hasWallet: Bool {
        return address != ""
    }
    
    var ethBalance: BigInt {
        guard let b = BigInt(eth_balance_string, radix: 16) else { return BigInt.init(0) }
        return b
    }
    
    var convertedEthBalance: Decimal {
        return EtherNumberFormatter.init().decimal(from: ethBalance, decimals: 18)!
    }
    
    var convertedSnipBalance: Decimal {
        return EtherNumberFormatter.init().decimal(from: snipBalance, decimals: 18)!
    }
    
    var snipBalance: BigInt {
        guard let b = BigInt(snip_balance_string, radix: 16) else { return BigInt.init(0) }
        return b
    }
    
    var readableSnipBalance: String {
        return EtherNumberFormatter.init().string(from: snipBalance)
    }
    
    var readableEthBalance: String {
        return EtherNumberFormatter.short.string(from: ethBalance)
    }
    
    func compareRemoteNonce(remote: Int) -> Int {
        if local_nonce > remote {
            return local_nonce
        } else {
            return remote
        }
    }
    
    func updateLocalNonce(remote: Int) {
        if remote >= local_nonce {
            try! self.realm?.write {
                self.local_nonce = remote + 1
            }
        }
    }
    
    func addPendingTransaction(to: String, amount: BigInt, coinType: CoinType, hash: String) -> Transaction {
        let t = Transaction()
        t.to_address = to
        t.from_address = address
        t.coin_type_string = coinType == .eth ? "eth" : "snip"
        t.transaction_hash = hash
        t.amount_string = (coinType == .eth ? String(amount, radix: 16) : String(amount, radix: 16))
        
        try! self.realm!.write {
            realm!.add(t, update: true)
            if transactions.index(of: t) == nil {
                transactions.append(t)
            }
        }
        return t
    }
}
