//
//  Link.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/16/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
class Link: Object {
    dynamic var title: String = ""
    dynamic var url: String = ""
}

extension Link {
    static func parseJson(json: [String: Any]) throws -> Link {
        guard let title = json["title"] as? String else { throw SerializationError.missing("title") }
        guard let url = json["url"] as? String else { throw SerializationError.missing("link") }
        let l = Link()
        l.title = title
        l.url = url
        return l
    }
}
