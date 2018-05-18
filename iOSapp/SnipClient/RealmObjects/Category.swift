//
//  Category.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/16/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
class Category: Object {
    let posts = List<Post>()
    let params = List<CategoryParam>()
    
    dynamic var categoryName: String = ""
    dynamic var url: String = ""
    
    override static func primaryKey() -> String? {
        return "categoryName"
    }
}

extension Category {
    static func parseJson(json: [String: Any]) throws -> Category {
        let c = Category()
        guard let cat = json["category"] as? String else { throw SerializationError.missing("category") }
        guard let url = json["url"] as? String else { throw SerializationError.missing("url") }
        guard let topThree = json["posts"] as? [ [String: Any] ] else { throw SerializationError.missing("posts") }
        for postJson in topThree {
            let p = try Post.parseJson(json: postJson)
            c.posts.append(p)
        }
        
        guard let paramDict = json["params"] as? [String: Any] else { throw SerializationError.missing("params") }
        guard let paramList = paramDict as? [String: String] else { throw SerializationError.invalid("params", paramDict)}
        for (param, value) in paramList {
            let catParam = try CategoryParam.parseJson(param: param, value: value)
            c.params.append(catParam)
        }
        c.url = url
        c.categoryName = cat
        return c
    }
    
    static func parseJsonList(json: [ [String: Any] ] ) throws -> [ Category ] {
        var catList: [ Category ] = []
        for catJson in json {
            let c = try Category.parseJson(json: catJson)
            catList.append(c)
        }
        return catList
    }
}
