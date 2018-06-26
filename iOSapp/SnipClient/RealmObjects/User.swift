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
    dynamic var first_name: String = ""
    dynamic var last_name: String = ""
    dynamic var avatarUrl: String = ""
    //dynamic var avatarImage: Image?
    dynamic var initials: String = ""
    dynamic var wallet_address: String? = nil
    
    override static func primaryKey() -> String? {
        return "username"
    }
    
    /**
    func hasAvatarImageData() -> Bool {
        guard let img = self.avatarImage else {
            return false
        }
        
        if img.imageUrl != self.avatarUrl {
            return false
        }
        
        guard let data = img.data else {
            return false
        }
        
        return data.count > 0
    }
    **/
}

extension User {
    static func parseJson(json: [String: Any]) throws -> User {
        let u = User()
        guard let username = json["username"] as? String else { throw SerializationError.missing("username") }
        var first_name = ""
        var last_name = ""
        if let name = json["name"] as? String {
            let split = name.split(separator: " ")
            if split.count != 2 {
                first_name = name
            } else {
                first_name = String(split[0])
                last_name = String(split[1])
            }
        } else {
            guard let fn = json["first_name"] as? String else { throw SerializationError.missing("first_name") }
            guard let ln = json["last_name"] as? String else { throw SerializationError.missing("last_name") }
            first_name = fn
            last_name = ln
        }
        
        guard let avatar = json["avatar"] as? String else { throw SerializationError.missing("avatar") }
        
        //Optional, found in some places
        if let initials = json["initials"] as? String {
            u.initials = initials
        } else {
            if first_name.count > 0 && last_name.count > 0 {
                let first = String(first_name[first_name.startIndex...first_name.startIndex])
                let last = String(last_name[last_name.startIndex...last_name.startIndex])
                u.initials = "\(first)\(last)".uppercased()
            }
        }
        if let addr = json["wallet_address"] as? String {
            u.wallet_address = addr
        }
        u.username = username
        u.first_name = first_name
        u.last_name = last_name
        u.avatarUrl = avatar
        return u
    }
}
