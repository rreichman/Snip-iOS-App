//
//  Image.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/17/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
class Image: Object {
    dynamic var imageUrl: String = ""
    dynamic var imageDescription: String = ""
    dynamic var deleted: Bool = false
    dynamic var imageHeight: Int = 0
    dynamic var imageWidth: Int = 0
    dynamic var data: Data? = nil
    dynamic var failed_loading: Bool = false
    
    override static func primaryKey() -> String? {
        return "imageUrl"
    }
    
    var hasData: Bool {
        return data != nil && data!.count > 0
    }
}

extension Image {
    static func parseJson(json: [String: Any]) throws -> Image {
        guard let url = json["url"] as? String else { throw SerializationError.missing("url") }
        guard let description = json["description"] as? String else { throw SerializationError.missing("description") }
        guard let deleted = json["deleted"] as? Bool else { throw SerializationError.missing("deleted") }
        guard let width = json["width"] as? Int else { throw SerializationError.missing("width") }
        guard let height = json["height"] as? Int else { throw SerializationError.missing("height") }
        
        let i = Image()
        i.imageUrl = url
        i.imageDescription = description
        i.deleted = deleted
        i.imageHeight = height
        i.imageWidth = width
        return i
    }
}
