//
//  PostData.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/29/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class PostData : Encodable, Decodable
{
    var postJson : [String : Any] = [:]
    var id : Int = 0
    var author : SnipUser = SnipUser()
    var headline : String = ""
    var text : String = ""
    // Perhaps store the date as something else in the future (not sure)
    var date : String = ""
    var image : SnipImage = SnipImage()
    var relatedLinks : [[String : Any]] = []
    var isLiked : Bool = false
    var isDisliked : Bool = false
    var comments : [Comment] = []
    
    // These two variables save resources when scrolling
    var imageDescriptionAfterHtmlRendering : NSMutableAttributedString = NSMutableAttributedString()
    var textAfterHtmlRendering : NSMutableAttributedString = NSMutableAttributedString()
    
    init()
    {
    }
    
    init(receivedPostJson : [String : Any])
    {
        postJson = receivedPostJson
        loadRawJsonIntoVariables()
        
        DispatchQueue.main.async
        {
            let imageDescriptionAttributes : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().IMAGE_DESCRIPTION_TEXT_FONT!, NSAttributedStringKey.foregroundColor : SystemVariables().IMAGE_DESCRIPTION_COLOR]
            let imageDescriptionString : NSMutableAttributedString = NSMutableAttributedString(htmlString : self.image._imageDescription)!
            imageDescriptionString.addAttributes(imageDescriptionAttributes, range: NSRange(location: 0,length: imageDescriptionString.length))
            self.imageDescriptionAfterHtmlRendering = imageDescriptionString
            
            self.textAfterHtmlRendering = NSMutableAttributedString(htmlString: self.text)!
        }
    }
    
    func setImageIfExists(postJson : [String : Any])
    {
        if postJson["image"] != nil
        {
            if !(postJson["image"] is NSNull)
            {
                image = SnipImage(imageData: postJson["image"] as! [String : Any])
            }
        }
    }
   
    func loadRawJsonIntoVariables()
    {
        id = postJson["id"] as! Int
        if (postJson["author"] == nil)
        {
            author = SnipUser(userData: ["name" : "authorName", "username": "authorUsername"])
        }
        else
        {
            author = SnipUser(userData: postJson["author"] as! [String : Any])
        }
        headline = postJson["title"] as! String
        text = postJson["body"] as! String
        date = postJson["date"] as! String
        setImageIfExists(postJson: postJson)
        relatedLinks = postJson["related_links"] as! [[String : Any]]
        isLiked = (postJson["votes"] as! [String : Bool])["like"]!
        isDisliked = (postJson["votes"] as! [String : Bool])["dislike"]!
        comments = convertJsonArrayIntoCommentArray(commentArrayData: postJson["comments"] as! [[String : Any]])
    }
    
    func convertJsonArrayIntoCommentArray(commentArrayData : [[String : Any]]) -> [Comment]
    {
        var comments : [Comment] = []
        
        for commentData in commentArrayData
        {
            comments.append(Comment(commentData: commentData))
        }
        
        return comments
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.singleValueContainer()
        try container.encode(postJson)
    }
    
    required init(from decoder: Decoder) throws
    {
        postJson = try decoder.singleValueContainer() as! [String : Any]
        loadRawJsonIntoVariables()
    }
}

/*public class Comments
{
    var comments : [Comment] = []
    
    init()
    {
    }
    
    init(commentArrayData : [[String : Any]])
    {
        for commentData in commentArrayData
        {
            var newComment = Comment(commentData: commentData)
            comments.append(newComment)
        }
    }
}*/
