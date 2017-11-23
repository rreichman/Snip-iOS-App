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
    var comments : Comments = Comments()
    
    init()
    {
    }
    
    init(receivedPostJson : [String : Any])
    {
        postJson = receivedPostJson
        loadRawJsonIntoVariables()
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
        comments = Comments(commentArrayData: postJson["comments"] as! [[String : Any]])
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

public class Comment
{
    var body : String = ""
    var date : String = ""
    var id : Int = 0
    var level : Int = 0
    var parent : Int = 0
    var writer : SnipUser = SnipUser()
    
    init()
    {
        
    }
    
    init(commentData: [String : Any])
    {
        body = commentData["body"] as! String
        date = commentData["date"] as! String
        id = commentData["id"] as! Int
        level = commentData["level"] as! Int

        if (commentData["parent"] is NSNull)
        {
            parent = 0
        }
        else
        {
            parent = commentData["parent"] as! Int
        }
        
        writer = SnipUser(userData: commentData["user"] as! [String : Any])
    }
}

public class Comments
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
}

public class SnipUser
{
    var _username : String = ""
    var _name : String = ""
    
    init()
    {
    }
    
    init(username : String, name : String)
    {
        _username = username
        _name = name
    }
    
    init(userData : [String : Any])
    {
        _username = userData["username"] as! String
        _name = userData["name"] as! String
    }
}

public class SnipImage
{
    var _imageURL : String = ""
    var _imageDescription : String = ""
    
    init()
    {
    }
    
    init(imageURL : String, imageDescription: String)
    {
        _imageURL = imageURL
        _imageDescription = imageDescription
    }
    
    init(imageData : [String : Any])
    {
        _imageURL = imageData["url"] as! String
        _imageDescription = imageData["description"] as! String
    }
}
