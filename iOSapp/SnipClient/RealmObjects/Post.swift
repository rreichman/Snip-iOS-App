//
//  Post.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/16/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
class Post: Object {
    
    dynamic var id : Int = 0
    dynamic var author : User?
    dynamic var headline : String = ""
    dynamic var text : String = ""
    // Perhaps store the date as something else in the future (not sure)
    dynamic var date : Date = Date()
    dynamic var timestamp: Int = 0
    dynamic var image: Image? = nil
    dynamic var isLiked : Bool = false
    dynamic var isDisliked : Bool = false
    dynamic var voteValue: Float = 0
    dynamic var fullURL : String = ""
    
    let comments = List<RealmComment>()
    let relatedLinks = List<Link>()
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    
    
}


extension Post {
    static func parseJson(json: [String: Any]) throws -> Post {
        let post = Post()
        post.id = json["id"] as! Int
        if let author = json["author"] as? [String: Any] {
            let user = try User.parseJson(json: author)
            post.author = user
        }
        post.headline = json["title"] as! String
        post.text = json["body"] as! String
        //post.setImageIfExists(json: json)
        
        if let rl = json["related_Links"] as? [ [String: Any] ] {
            for obj in rl {
                let l = try Link.parseJson(json: obj)
                post.relatedLinks.append(l)
            }
        }
        
        guard let imageJson = json["image"] as? [String: Any] else { throw SerializationError.missing("image") }
        post.image = try Image.parseJson(json: imageJson)
        
        guard let vote = json["votes"] as? [String: Any] else { throw SerializationError.missing("votes")}
        guard let like = vote["like"] as? Bool else { throw SerializationError.missing("like")}
        guard let dislike = vote["dislike"] as? Bool else { throw SerializationError.missing("dislike")}
        guard let vote_value = vote["value"] as? Float else { throw SerializationError.missing("value")}
        post.isLiked = like
        post.isDisliked = dislike
        post.voteValue = vote_value
        
        post.fullURL = json["url"] as! String
        guard let commentJson = json["comments"] as? [ [String: Any] ] else { throw SerializationError.missing("comments") }
        for comment in commentJson {
            let c = try RealmComment.parseJson(json: comment)
            post.comments.append(c)
        }
        
        
        return post
    }
}
