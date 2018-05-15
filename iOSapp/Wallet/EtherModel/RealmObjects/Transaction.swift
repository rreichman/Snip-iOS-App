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
    dynamic var failed: Bool = false
    dynamic var shouldIgnore: Bool = false
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
        
        guard let b = BigInt(amount_string, radix: 16) else { return BigInt.init(0) }
        return b
        
    }
    
    var status: String {
        if failed {
            return "Failed"
        }
        if !inNetwork {
            return "Pending"
        }
        if confirmations == 0 {
            return "Pending"
        } else if confirmations == 1 {
            return "1 Confirmation"
        } else if confirmations < 13 {
            return "\(confirmations) Confirmations"
        } else {
            return "Confirmed"
        }
    }
    
    func sent(local address: String) -> Bool {
        return from_address == address
    }
    
    override static func primaryKey() -> String? {
        return "transaction_hash"
    }
    
}

extension Transaction {
    static func parseEtherscanTransaction(json: [String: Any]) throws -> Transaction {
        guard let receipt_string = json["txreceipt_status"] as? String else { throw SerializationError.missing("txreceipt_status") }
        guard let error_string = json["isError"] as? String else { throw SerializationError.missing("isError") }
        guard let con = json["confirmations"] as? String else { throw SerializationError.missing("confirmations")}
        guard let conInt = Int(con) else { throw SerializationError.invalid("Int(\"confirmations\")", con)}
        guard var to_address = json["to"] as? String else { throw SerializationError.missing("to") }
        guard let from_address = json["from"] as? String else { throw SerializationError.missing("from") }
        var coin_type_string: String!
        
        
        guard let timestamp = json["timeStamp"] as? String else {throw SerializationError.missing("timestamp") }
        guard let timestampInt = Int(timestamp) else { throw SerializationError.invalid("Int(timestamp", timestamp) }
        let date = Date(timeIntervalSince1970: TimeInterval(timestampInt))
        guard let transaction_hash = json["hash"] as? String else { throw SerializationError.missing("hash") }
        
        var amount_string: String!
        var amountBigInt: BigInt!
        var shouldIgnore: Bool = false
        if to_address == NetworkSettings.getNetwork().contract_address {
            coin_type_string = "snip"
        } else {
            coin_type_string = "eth"
        }
        if coin_type_string == "snip" {
            guard let amt = json["input"] as? String else { throw SerializationError.missing("input") }
            if !amt.starts(with: "0xa9059cbb") {
                shouldIgnore = true
                amount_string = "0"
                amountBigInt = BigInt(0)
            } else {
                let amt_sub = String(amt[amt.index(amt.startIndex, offsetBy:74)...])
                guard let bg = BigInt(amt_sub, radix: 16) else { throw SerializationError.invalid("BigInt(amt)", amt) }
                amount_string = amt_sub
                amountBigInt = bg
                to_address = "0x" + String(amt[amt.index(amt.startIndex, offsetBy:34)..<amt.index(amt.startIndex, offsetBy:74)])
            }
        } else {
            guard let amt = json["value"] as? String else { throw SerializationError.missing("input") }
            guard let bg = BigInt(amt, radix: 10) else { throw SerializationError.invalid("BigInt(amt)", amt) }
            amount_string = amt
            amountBigInt = bg
            if let input = json["input"] as? String {
                if amountBigInt == BigInt(0) && input.count > 2 {
                    shouldIgnore = true
                }
            }
        }
        
        
        let t = Transaction()
        if receipt_string != "1" || error_string != "0" {
            //failed transaction
            t.failed = true
        } else {
            t.failed = false
        }
        t.shouldIgnore = shouldIgnore
        t.inNetwork = true
        t.confirmations = conInt >= 13 ? 13 : conInt
        t.to_address = to_address
        t.from_address = from_address
        t.timestamp = timestampInt
        t.coin_type_string = coin_type_string
        t.date = date
        t.transaction_hash = transaction_hash
        t.amount_string = String(amountBigInt, radix: 16)
        return t
    }
    
    static func parseEtherscanLogTransaction(json: [String: Any]) throws -> Transaction {
        guard let topics = json["topics"] as? [String] else { throw SerializationError.missing("topics") }
        if  (topics.count < 3) {
            throw SerializationError.missing("topics")
        }
        let topic1 = topics[1]
        let topic2 = topics[2]
        guard let timestamp = json["timeStamp"] as? String else {throw SerializationError.missing("timestamp") }
        let strip_timestamp = String(timestamp[timestamp.index(timestamp.startIndex, offsetBy:2)...])
        guard let timestampInt = Int(strip_timestamp, radix: 16) else { throw SerializationError.invalid("Int(timestamp", timestamp) }
        let date = Date(timeIntervalSince1970: TimeInterval(timestampInt))
        guard let transaction_hash = json["transactionHash"] as? String else { throw SerializationError.missing("hash") }
        guard let data_string = json["data"] as? String else { throw SerializationError.missing("value") }
        let amount_string = String(data_string[data_string.index(data_string.startIndex, offsetBy: 2)...])
        guard let amountBigInt = BigInt(amount_string, radix: 16) else { throw SerializationError.invalid("BigInt(amount_string", amount_string) }
        
        
        let t = Transaction()
        t.inNetwork = true
        t.confirmations = 13 // Don't have access to confirmations for log responses, using 13 to represent confirmed
        t.to_address = "0x\(topic2[topic2.index(topic2.startIndex, offsetBy: 26)...])"
        t.from_address = "0x\(topic1[topic1.index(topic1.startIndex, offsetBy: 26)...])"
        t.timestamp = timestampInt
        t.date = date
        t.coin_type_string = "snip"
        t.transaction_hash = transaction_hash
        t.amount_string = String(amountBigInt, radix: 16)
        return t
    }
    
    static func parseEtherscanTransactionList(json: [String: Any], isLog: Bool ) throws -> [Transaction] {
        guard let status = json["status"] as? String else { throw SerializationError.missing("status") }
        guard let message = json["message"] as? String else { throw SerializationError.missing("message") }
        
        if status != "1" { throw APIError.badStatus(message: status) }
        if message != "OK" { throw APIError.badMessage(message: message) }
        
        guard let results = json["result"] as? [ [String: Any] ] else { throw SerializationError.missing("result") }
        var list: [Transaction] = []
        for result in results {
            if isLog {
                let t = try Transaction.parseEtherscanLogTransaction(json: result)
                list.append(t)
            } else {
                let t = try Transaction.parseEtherscanTransaction(json: result)
                list.append(t)
            }
            
        }
        
        return list
    }
}
