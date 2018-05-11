//
//  GasData.swift
//  iOSapp
//
//  Created by CJ Zeiger on 5/8/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import BigInt
import RealmSwift

@objcMembers
class GasData: Object {
    dynamic var lowPrice: Int = 0
    dynamic var lowTime: Double = 0.0
    dynamic var mediumPrice: Int = 0
    dynamic var mediumTime: Double = 0.0
    dynamic var highPrice: Int = 0
    dynamic var highTime: Double = 0.0
    dynamic var user_selection_int: Int = 0
    dynamic var from: Date = Date()
    
    dynamic var key: String = "gas_data"
    
    override static func primaryKey() -> String? {
        return "key"
    }
    
    var userSelection: GasSetting {
        switch user_selection_int {
        case 2:
            return .high
        case 1:
            return .medium
        case 0:
            return .low
        default:
            return .low
        }
    }
    
    func setUserSelection(to setting: GasSetting) {
        switch setting {
        case .low:
            user_selection_int = 0
        case .medium:
            user_selection_int = 1
        case .high:
            user_selection_int = 2
        }
    }
    
    func priceInWei(for mode: GasSetting) -> BigInt {
        let price = priceInt(for: mode)
        return BigInt(price) * BigInt(100000000)
    }
    
    func humanReadableTime(for mode: GasSetting) -> String {
        let time = timeDouble(for: mode)
        if time <= 1.0 {
            return "\(Int( (time * 60.0) - Double((Int(time) * 60)) ) )s"
        } else {
            return "\(Int(time))m \(Int( (time * 60.0) - Double((Int(time) * 60)) ) )s"
        }
    }
    
    func humanReadablePrice(for mode: GasSetting) -> String {
        let price = priceInt(for: mode)
        if price < 10 {
            return "\(Double(price) / 10.0) gwei"
        } else {
            return "\(price/10) gwei"
        }
    }
    
    func timeDouble(for mode: GasSetting) -> Double {
        switch mode {
        case .low:
            return lowTime
        case .medium:
            return mediumTime
        case .high:
            return highTime
        }
    }
    
    func priceInt(for mode: GasSetting) -> Int {
        switch mode {
        case .low:
            return lowPrice
        case .medium:
            return mediumPrice
        case .high:
            return highPrice
        }
    }
    
    public static func labelForSetting(for setting: GasSetting) -> String {
        switch setting {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }
    
    static func parseJson(of json: [String: Any]) throws -> GasData {
        guard let lowPrice = json["safeLow"] as? Int else { throw SerializationError.missing("safeLow") }
        guard let lowTime = json["safeLowWait"] as? Double else { throw SerializationError.missing("safeLowWait") }
        guard let average = json["average"] as? Int else { throw SerializationError.missing("avareage")  }
        guard let averageWait = json["avgWait"] as? Double else { throw SerializationError.missing("averageWait" ) }
        
        guard let fast = json["fast"] as? Int else { throw SerializationError.missing("fast") }
        guard let fastWait = json["fastWait"] as? Double else {throw SerializationError.missing("fastWait") }
        
        let new = GasData()
        
        new.lowTime = lowTime
        new.lowPrice = lowPrice
        new.mediumTime = averageWait
        new.mediumPrice = average
        new.highPrice = fast
        new.highTime = fastWait
        
        return new
    }
}
