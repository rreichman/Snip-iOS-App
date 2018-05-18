//
//  User.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/16/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import RealmSwift


@objcMembers
class User: Object {
    dynamic var username: String = ""
    dynamic var name: String = ""
    dynamic var avatarUrl: String = ""
    dynamic var initials: String = ""
    dynamic var wallet_address: String? = nil
    
    override static func primaryKey() -> String? {
        return "username"
    }
    
}

extension User {
    static func parseJson(json: [String: Any]) throws -> User {
        let u = User()
        guard let username = json["username"] as? String else { throw SerializationError.missing("username") }
        guard let name = json["name"] as? String else { throw SerializationError.missing("name") }
        guard let avatar = json["avatar"] as? String else { throw SerializationError.missing("avatar") }
        guard let initials = json["initials"] as? String else { throw SerializationError.missing("initials") }
        if let addr = json["wallet_address"] as? String {
            u.wallet_address = addr
        }
        u.username = username
        u.name = name
        u.initials = initials
        return u
    }
}
