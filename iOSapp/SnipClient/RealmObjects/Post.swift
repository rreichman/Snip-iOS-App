//
//  Post.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/16/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import RealmSwift
import Crashlytics

@objcMembers
class Post: Object {
    static let dateFormatter: DateFormatter = DateFormatter()
    dynamic var id : Int = 0
    dynamic var author : User?
    dynamic var headline : String = ""
    dynamic var text : String = ""
    // Perhaps store the date as something else in the future (not sure)
    dynamic var date : Date = Date()
    dynamic var timestamp: Int = 0
    dynamic var image: Image? = nil
    dynamic var voteValue: Double = 0
    dynamic var fullURL : String = ""
    dynamic var saved: Bool = false
    
    let comments = List<RealmComment>()
    let relatedLinks = List<Link>()
    dynamic var postHasBeenViewed: Bool = false
    dynamic var postHasBeenExpanded: Bool = false
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["dateFormatter", "postHasBeenViewed", "postHasBeenExpanded"]
    }
    
    func formattedTimeString() -> String {
        return TimeUtils.getFormattedDateString(date: self.date)
    }
    
}


extension Post {
    static func parseJson(json: [String: Any]) throws -> Post {
        let post = Post()
        guard let id = json["id"] as? Int else {
            throw SerializationError.missing("id")
        }
        post.id = id
        if let author = json["author"] as? [String: Any] {
            let user = try User.parseJson(json: author)
            post.author = user
        }
        guard let headline = json["title"] as? String else {
            throw SerializationError.missing("title")
        }
        post.headline = headline
        guard let body = json["body"] as? String else {
            throw SerializationError.missing("body")
        }
        post.text = body
        
        if let rl = json["related_links"] as? [ [String: Any] ] {
            for obj in rl {
                let l = try Link.parseJson(json: obj)
                post.relatedLinks.append(l)
            }
        }
        if let imageJson = json["image"] as? [String: Any] {
            if let image = try? Image.parseJson(json: imageJson) {
                if let cached_image = RealmManager.instance.getMemRealm().object(ofType: Image.self, forPrimaryKey: image.imageUrl) {
                    post.image = cached_image
                } else {
                    post.image = image
                }
            } else {
                post.image = nil
            }
        } else {
            post.image = nil
        }
        
        guard let vote = json["votes"] as? [String: Any] else { throw SerializationError.missing("votes")}
        guard let vote_value = vote["value"] as? Double else { throw SerializationError.missing("value")}
        post.voteValue = vote_value
        
        post.fullURL = json["url"] as! String
        guard let commentJson = json["comments"] as? [ [String: Any] ] else { throw SerializationError.missing("comments") }
        for comment in commentJson {
            let c = try RealmComment.parseJson(json: comment)
            post.comments.append(c)
        }
        guard let saved = json["saved"] as? Bool else { throw SerializationError.missing("saved") }
        post.saved = saved
        guard let timestamp = json["timestamp"] as? Double else { throw SerializationError.missing("timestamp") }
        let date = Date(timeIntervalSince1970: timestamp.rounded())
        post.date = date
        
        return post
    }
    
    static func parsePostPage(json: [String: Any]) throws -> [ Post ] {
        guard let list = json["posts"] as? [ [String: Any] ] else { throw SerializationError.missing("posts") }
        
        var parsedList: [ Post ] = []
        for postJson in list {
            do {
                let post = try parseJson(json: postJson)
                parsedList.append(post)
            } catch {
                print("Error parsing post JSON \(postJson)")
                Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: postJson)
            }
        }
        return parsedList
    }
    
    func calculateCommentArray() -> [ RealmComment ] {
        if self.comments.count == 0 {
            return []
        }
        var post_comments = self.formList(from: self.comments)
        post_comments.sort { (c1, c2) -> Bool in
            return c1.date.compare(c2.date).rawValue > 0
        }
        self.nestTimeSortedCommentArray(of: post_comments)
        var unNestedComments: [ RealmComment ] = []
        for comment in post_comments {
            if comment.level == 0 {
                unNestedComments.append(contentsOf: flattenComments(parent: comment))
            }
        }
        return unNestedComments
    }
    
    func flattenComments(parent: RealmComment) -> [ RealmComment ] {
        var flat: [ RealmComment ] = []
        flat.append(parent)
        if parent.childComments.count > 0 {
            for child in parent.childComments {
                flat.append(contentsOf: flattenComments(parent: child))
            }
        }
        return flat
    }
    
    func nestTimeSortedCommentArray(of flatComments: [ RealmComment ]){
        //TODO: really bad efficency fix later. Should be find for small comment numbers
        for comment in flatComments {
            for possibleChild in flatComments {
                if let parent_id = possibleChild.parent_id.value {
                    if parent_id == comment.id {
                        comment.childComments.append(possibleChild)
                    }
                }
            }
        }
    }
    
    func formList(from commentList: List<RealmComment>) -> [ RealmComment ] {
        var result: [ RealmComment ] = []
        for i in 0..<commentList.count {
            result.append(commentList[i])
        }
        return result
    }
}
