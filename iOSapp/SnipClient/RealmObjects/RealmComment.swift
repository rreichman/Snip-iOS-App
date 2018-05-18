//
//  RealmComment.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/16/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
class RealmComment: Object {
    
    dynamic var body : String = ""
    dynamic var date_string : String = ""
    dynamic var id : Int = 0
    dynamic var level : Int = 0
        dynamic var writer : User?
    dynamic var parent : RealmComment?
    
    let subComments = List<RealmComment>()
    let parent_id = RealmOptional<Int>()

}


extension RealmComment {
    static func parseJson(json: [String: Any]) throws -> RealmComment {
        let comment = RealmComment()
        guard let id = json["id"] as? Int else { throw SerializationError.missing("id") }
        guard let date_string = json["date"] as? String else { throw SerializationError.missing("date") }
        guard let body = json["body"] as? String else { throw SerializationError.missing("body") }
        guard let level = json["level"] as? Int else { throw SerializationError.missing("level") }
        if let parent_id = json["parent"] as? Int {
            comment.parent_id.value = parent_id
        }
        if let userJson = json["user"] as? [String: Any] {
            let u = try User.parseJson(json: userJson)
            comment.writer = u
        }
        
        comment.id = id
        comment.date_string = date_string
        comment.body = body
        comment.level = level
        
        return comment
    }
}
