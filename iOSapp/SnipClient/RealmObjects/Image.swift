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
        
        let i = Image()
        
        if let width = json["width"] as? Int {
            i.imageWidth = width
        }
        if let height = json["height"] as? Int {
            i.imageHeight = height
        }
        if let deleted = json["deleted"] as? Bool {
            i.deleted = deleted
        }
        if let description = json["description"] as? String {
            i.imageDescription = description
        }
        
        i.imageUrl = url
        return i
    }
    
    static func buildSimpleImage(with url: String) -> Image {
        let i = Image()
        i.imageUrl = url
        return i
    }
}
