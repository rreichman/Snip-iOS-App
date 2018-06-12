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
    dynamic var id : Int = 0
    dynamic var level : Int = 0
    dynamic var writer : User?
    dynamic var parent : RealmComment?
    dynamic var date: Date = Date()
    
    
    var childComments: [ RealmComment] = []
    
    override static func ignoredProperties() -> [String] {
        return ["childComments"]
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func formattedTimeString() -> String {
        return TimeUtils.getFormattedDateString(date: self.date)
    }
    
    let subComments = List<RealmComment>()
    let parent_id = RealmOptional<Int>()

}


extension RealmComment {
    static func parseJson(json: [String: Any]) throws -> RealmComment {
        let comment = RealmComment()
        guard let id = json["id"] as? Int else { throw SerializationError.missing("id") }
        guard let body = json["body"] as? String else { throw SerializationError.missing("body") }
        guard let level = json["level"] as? Int else { throw SerializationError.missing("level") }
        if let parent_id = json["parent"] as? Int {
            comment.parent_id.value = parent_id
        }
        if let userJson = json["user"] as? [String: Any] {
            let u = try User.parseJson(json: userJson)
            comment.writer = u
        }
        
        guard let timestamp = json["timestamp"] as? Double else { throw SerializationError.missing("timestamp") }
        let date = Date(timeIntervalSince1970: timestamp.rounded())
        comment.date = date
        
        
        comment.id = id
        comment.body = body
        comment.level = level
        
        return comment
    }
}
