//
//  Transaction.swift
//  iOSapp
//
//  Created by CJ Zeiger on 5/4/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import BigInt
import RealmSwift

@objcMembers
class Transaction: Object {
    dynamic var inNetwork: Bool = false
    dynamic var confirmations: Int = 0
    dynamic var to_address: String = ""
    dynamic var from_address: String = ""
    dynamic var timestamp: Int = 0
    dynamic var date: Date = Date()
    dynamic var coin_type_string: String = "eth"
    dynamic var transaction_hash: String = ""
    dynamic var amount_string: String = "0"
    
    var coinType: CoinType {
        switch coin_type_string {
        case "eth":
            return CoinType.eth
        case "snip":
            return CoinType.snip
        default:
            return CoinType.eth
        }
    }
    
    var amount: BigInt {
        guard let b = BigInt(amount_string, radix: 10) else { return BigInt.init(0) }
        return b
    }
    
    override static func primaryKey() -> String? {
        return "transaction_hash"
    }
    
}

extension Transaction {
    static func parseEtherscanTransaction(json: [String: Any]) throws -> Transaction {
        guard let con = json["confirmations"] as? String else { throw SerializationError.missing("confirmations")}
        guard let conInt = Int(con) else { throw SerializationError.invalid("Int(\"confirmations\")", con)}
        guard let to_address = json["to"] as? String else { throw SerializationError.missing("to") }
        guard let from_address = json["from"] as? String else { throw SerializationError.missing("from") }
        guard let timestamp = json["timeStamp"] as? String else {throw SerializationError.missing("timestamp") }
        guard let timestampInt = Int(timestamp) else { throw SerializationError.invalid("Int(timestamp", timestamp) }
        let date = Date(timeIntervalSince1970: TimeInterval(timestampInt))
        guard let transaction_hash = json["hash"] as? String else { throw SerializationError.missing("hash") }
        guard let amount_string = json["value"] as? String else { throw SerializationError.missing("value") }
        guard let amountBigInt = BigInt(amount_string, radix: 10) else { throw SerializationError.invalid("BigInt(amount_string", amount_string) }
        
        
        let t = Transaction()
        t.inNetwork = true
        t.confirmations = conInt
        t.to_address = to_address
        t.from_address = from_address
        t.timestamp = timestampInt
        t.date = date
        if to_address == NetworkSettings.main_net.contract_address || to_address == NetworkSettings.rinkeby.contract_address {
            t.coin_type_string = "snip"
        } else {
            t.coin_type_string = "eth"
        }
        t.transaction_hash = transaction_hash
        t.amount_string = amount_string
        return t
    }
    
    static func parseEtherscanTransactionList(json: [String: Any] ) throws -> [Transaction] {
        guard let status = json["status"] as? String else { throw SerializationError.missing("status") }
        guard let message = json["message"] as? String else { throw SerializationError.missing("message") }
        
        if status != "1" { throw APIError.badStatus(message: status) }
        if message != "OK" { throw APIError.badMessage(message: message) }
        
        guard let results = json["result"] as? [ [String: Any] ] else { throw SerializationError.missing("result") }
        var list: [Transaction] = []
        for result in results {
            let t = try Transaction.parseEtherscanTransaction(json: result)
            list.append(t)
        }
        
        return list
    }
}
