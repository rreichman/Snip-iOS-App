//
//  UserWallet.swift
//  iOSapp
//
//  Created by CJ Zeiger on 5/4/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
class UserWallet: Object {
    let transactions = List<Transaction>()
    dynamic var address: String = ""
    dynamic var eth_balance_string: String = "0x0"
    dynamic var snip_balance_string: String = "0x0"
    
    
    var hasWallet: Bool {
        return address != ""
    }
}
