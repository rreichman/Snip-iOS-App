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
    var postJson : [String : Any]
    var id : Int
    var author : SnipAuthor
    var headline : String
    var text : String
    // Perhaps store the date as something else in the future (not sure)
    var date : String
    var image : SnipImage
    var relatedLinks : [[String : Any]]
    var isLiked : Bool
    var isDisliked : Bool
    
    init()
    {
        postJson = [:]
        id = 0
        author = SnipAuthor()
        headline = ""
        text = ""
        date = ""
        image = SnipImage()
        relatedLinks = []
        isLiked = false
        isDisliked = false
    }
    
    init(receivedPostJson : [String : Any])
    {
        postJson = receivedPostJson
        
        // These are default inits
        id = 0
        author = SnipAuthor()
        headline = ""
        text = ""
        date = ""
        image = SnipImage()
        relatedLinks = []
        isLiked = false
        isDisliked = false
        
        loadRawJsonIntoVariables()
    }
   
    func loadRawJsonIntoVariables()
    {
        id = postJson["id"] as! Int
        print (postJson["author"])
        if (postJson["author"] == nil)
        {
            print(postJson)
        }
        //author = SnipAuthor(authorData: postJson["author"] as! [String : Any])
        author = SnipAuthor(authorData: ["name" : "authorName", "username": "authorUsername"])
        headline = postJson["title"] as! String
        text = postJson["body"] as! String
        date = postJson["date"] as! String
        image = SnipImage(imageData: postJson["image"] as! [String : Any])
        relatedLinks = postJson["related_links"] as! [[String : Any]]
        isLiked = (postJson["votes"] as! [String : Bool])["like"]!
        isDisliked = (postJson["votes"] as! [String : Bool])["dislike"]!
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.singleValueContainer()
        try container.encode(postJson)
    }
    
    required init(from decoder: Decoder) throws
    {
        postJson = try decoder.singleValueContainer() as! [String : Any]
        
        id = 0
        author = SnipAuthor()
        headline = ""
        text = ""
        date = ""
        image = SnipImage()
        relatedLinks = []
        isLiked = false
        isDisliked = false
        
        loadRawJsonIntoVariables()
    }
}

public class SnipAuthor
{
    var _authorUsername : String
    var _authorName : String
    
    init()
    {
        _authorUsername = ""
        _authorName = ""
    }
    
    init(authorUsername : String, authorName : String)
    {
        _authorUsername = authorUsername
        _authorName = authorName
    }
    
    init(authorData : [String : Any])
    {
        _authorUsername = authorData["username"] as! String
        _authorName = authorData["name"] as! String
    }
}

public class SnipImage
{
    var _imageURL : String
    var _imageDescription : String
    
    init()
    {
        _imageURL = ""
        _imageDescription = ""
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
