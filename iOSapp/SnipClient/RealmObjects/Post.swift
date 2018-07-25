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

enum PostType {
    case Report
    case Explained
}

@objcMembers
class Post: Object {
    static let dateFormatter: DateFormatter = DateFormatter()
    static let paragraphStyle: NSParagraphStyle = {
        let p = NSMutableParagraphStyle()
        p.lineSpacing = 0
        p.paragraphSpacing = 0
        p.defaultTabInterval = 36
        p.baseWritingDirection = .leftToRight
        p.minimumLineHeight = 22
        return p
    }()
    static let relatedLinkParagraphStyle: NSParagraphStyle = {
        let p = NSMutableParagraphStyle()
        p.lineSpacing = 0
        p.paragraphSpacing = 0
        p.defaultTabInterval = 36
        p.baseWritingDirection = .leftToRight
        p.minimumLineHeight = 32
        return p
    }()
    
    static let emptyParagraph: NSAttributedString = NSAttributedString(string: "")
    dynamic var id : Int = 0
    dynamic var author : User?
    dynamic var headline : String = ""
    dynamic var text : String = ""
    dynamic var subheadline: String = ""
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
    
    dynamic var post_type_string: String = "report"
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["dateFormatter", "postHasBeenViewed", "postHasBeenExpanded",
                "postType", "_subheadlineCache", "_fullBodyCache", "subheadlineAttributedString",
                "fullBodyAttributedString", "emptyBody", "emptySubhead"]
    }
    
    func formattedTimeString() -> String {
        return TimeUtils.getFormattedDateString(date: self.date)
    }
    
    var postType: PostType {
        switch (self.post_type_string.lowercased()) {
        case "report":
            return PostType.Report
        case "explained":
            return PostType.Explained
        default:
            return PostType.Report
        }
    }
    
    var emptyBody: Bool {
        return self.text.count == 0
    }
    
    var emptySubhead: Bool {
        return self.subheadline.count == 0
    }
    
    var subheadlineAttributedString: NSAttributedString {
        get {
            let key = "\(id)\(subheadline)"
            if let c = AttributedStringCache.attributedStringForText(keyString: key) {
                return c
            }
            let result = getAttributedSubhead()
            AttributedStringCache.setCacheValue(attributedString: result, for: key)
            return result
        }
    }
    
    var fullBodyAttributedString: NSAttributedString {
        get {
            let key = "\(id)\(text)"
            if let c = AttributedStringCache.attributedStringForText(keyString: key) {
                return c
            }
            let result = getAttributedBodyWithRelatedLinks()
            AttributedStringCache.setCacheValue(attributedString: result, for: key)
            return result
        }
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
        
        if let subheadline = json["subtitle"] as? String {
            post.subheadline = subheadline
        }
        
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
        
        if let post_type = json["post_type"] as? String {
            post.post_type_string = post_type
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

extension Post {
    func getAttributedBody() -> NSAttributedString {
        
        if text == "" {
            return Post.emptyParagraph
        }
        //Possibly strip paragraphs
        let font_size: CGFloat = 15.0
        let line_height = 22
        let bodyColor = (self.postType == .Report && !self.emptySubhead) ? UIColor(white: 0.4, alpha: 1.0) : UIColor(white: 0.2, alpha: 1.0)
        let fixed_html = "<div style = \"line-height: \(line_height)px\">\(text)</div>"
        guard let render = NSMutableAttributedString(htmlString: fixed_html) else { return NSAttributedString(string: "") }
        render.addAttributes([NSAttributedStringKey.font: UIFont.lato(size: font_size), NSAttributedStringKey.foregroundColor: bodyColor, NSAttributedStringKey.paragraphStyle: Post.paragraphStyle], range: NSRange(location: 0, length: render.length))
        
        return render.attributedSubstring(from: NSMakeRange(0, render.length))
    }
    
    func getAttributedBodyMutable() -> NSMutableAttributedString? {
        let s = getAttributedBody()
        return s.mutableCopy() as! NSMutableAttributedString
    }
    func getAttributedSubhead() -> NSAttributedString {
        
        if subheadline == "" {
            return Post.emptyParagraph
        }
        //Possibly strip paragraphs
        let font_size: CGFloat = 15.0
        let line_height = 22
        let fixed_html = "<div style = \"line-height: \(line_height)px\">\(subheadline)</div>"
        guard let render = NSMutableAttributedString(htmlString: fixed_html) else { return NSAttributedString(string: "") }
        render.addAttributes([NSAttributedStringKey.font: UIFont.lato(size: font_size), NSAttributedStringKey.foregroundColor: UIColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1.0), NSAttributedStringKey.paragraphStyle: Post.paragraphStyle], range: NSRange(location: 0, length: render.length))
        return render.attributedSubstring(from: NSMakeRange(0, render.length))
    }
    
    func getAttributedSubheadMutable() -> NSMutableAttributedString? {
        let s = getAttributedSubhead()
        return s.mutableCopy() as! NSMutableAttributedString
    }
    
    func getAttributedBodyWithRelatedLinks() -> NSAttributedString {
        let body: NSMutableAttributedString = getAttributedBodyMutable()!
        
        for source in relatedLinks {
            guard let url = URL(string: source.url) else {
                print("Post \(id) has an invalid related link URL \(source.url)")
                Crashlytics.sharedInstance().recordError(SerializationError.invalid("Related link URL", source.url), withAdditionalUserInfo: ["title": source.title, "url": source.url, "post_id": id, "api_url": RestUtils.snipURLString])
                continue
            }
            let text = source.title
            let attributes: [NSAttributedStringKey : Any] =
                [.paragraphStyle: Post.relatedLinkParagraphStyle,
                 .font: UIFont.lato(size: 15),
                 .link: url,
                 .underlineStyle: 1]
            let spaceAttributes: [NSAttributedStringKey : Any] =
                [.paragraphStyle: Post.relatedLinkParagraphStyle,
                 .font: UIFont.lato(size: 15)]
            let attributedText = NSMutableAttributedString(string: text, attributes: attributes)
            body.append(attributedText)
            body.append(NSMutableAttributedString(string: ", ", attributes: spaceAttributes))
        }
        return (body.length > 2 ? body.attributedSubstring(from: NSMakeRange(0, body.length - 2)) : body)
    }
    
    func asViewModel(expanded: Bool) -> PostViewModel {
        let imageUrl: String = self.image?.imageUrl ?? ""
        
        return PostViewModel(
                            id: id,
                            title: self.headline,
                             subhead: self.subheadlineAttributedString,
                             body: self.fullBodyAttributedString,
                             authorName: (self.author != nil ? self.author!.fullName() : ""),
                             dateString: self.formattedTimeString(),
                             saved: self.saved,
                             imageUrl: imageUrl,
                             voteValue: self.voteValue,
                             urlString: self.fullURL,
                             numberOfComments: self.comments.count,
                             timestamp: self.timestamp.toString(),
                             expanded: expanded,
                             authorUsername: self.author != nil ? self.author!.username : "",
                             postType: self.postType,
                             emptyBody: self.emptyBody,
                             emptySubhead: self.emptySubhead)
    }
    
    func asDetailViewModel(activeUserUsername: String) -> PostDetailViewModel {
        let imageUrl: String = self.image?.imageUrl ?? ""
        return PostDetailViewModel(id: self.id,
                                   title: self.headline,
                                   subhead: self.subheadlineAttributedString,
                                   body: self.fullBodyAttributedString,
                                   authorName: (self.author != nil ? self.author!.fullName() : ""),
                                   dateString: self.formattedTimeString(),
                                   saved: self.saved,
                                   imageUrl: imageUrl,
                                   voteValue: self.voteValue,
                                   urlString: self.fullURL,
                                   numberOfComments: self.comments.count,
                                   authorUsername: self.author != nil ? self.author!.username : "",
                                   comments: self.calculateCommentArray().map({ (realmComment) -> CommentViewModel in
                                    return realmComment.asViewModel(activeUserUsername: activeUserUsername)
                                   }),
                                   authorAvatarUrl: self.author?.avatarUrl ?? "",
                                   authorInitials: self.author?.initials ?? "")
    }
}
