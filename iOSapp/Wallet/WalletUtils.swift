//
//  Utils.swift
//  iOSapp
//
//  Created by CJ Zeiger on 5/9/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation

class WalletUtils {
    
    static func validEthAddress(address: String) -> Bool {
        if address == "" {
            return false
        }
        return address.range(of: "^0x[a-fA-F0-9]{40}$", options: .regularExpression) != nil
    }
    
    static func dataToHexString(data: Data, addPrefix: Bool = true) -> String {
        var hex = data.map { String(format: "%02x", $0) }.joined()
        if addPrefix {
            hex = "0x" + hex
        }
        return hex
    }
}
