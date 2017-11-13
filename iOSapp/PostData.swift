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
    var _postJson : [String : Any]
    var _id : Int
    var _author : SnipAuthor
    var _headline : String
    var _text : String
    // TODO: perhaps store the date as something else in the future (not sure)
    var _date : String
    var _image : SnipImage
    var _relatedLinks : [[String : Any]]
    
    init()
    {
        _postJson = [:]
        _id = 0
        _author = SnipAuthor()
        _headline = ""
        _text = ""
        _date = ""
        _image = SnipImage()
        _relatedLinks = []
    }
    
    init(postJson : [String : Any])
    {
        _postJson = postJson
        
        _id = _postJson["id"] as! Int
        _author = SnipAuthor(authorData: _postJson["author"] as! [String : Any])
        _headline = _postJson["title"] as! String
        _text = _postJson["body"] as! String
        _date = _postJson["date"] as! String
        _image = SnipImage(imageData: _postJson["image"] as! [String : Any])
        _relatedLinks = _postJson["related_links"] as! [[String : Any]]
    }
   
    // TODO:: use this, there is bad duplicate code here
    func loadRawJsonIntoVariables()
    {
        _id = _postJson["id"] as! Int
        _author = SnipAuthor(authorData: _postJson["author"] as! [String : Any])
        _headline = _postJson["title"] as! String
        _text = _postJson["body"] as! String
        _date = _postJson["date"] as! String
        _image = SnipImage(imageData: _postJson["image"] as! [String : Any])
        _relatedLinks = _postJson["related_links"] as! [[String : Any]]
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.singleValueContainer()
        try container.encode(_postJson)
    }
    
    required init(from decoder: Decoder) throws
    {
        _postJson = try decoder.singleValueContainer() as! [String : Any]
        
        _id = _postJson["id"] as! Int
        _author = SnipAuthor(authorData: _postJson["author"] as! [String : Any])
        _headline = _postJson["title"] as! String
        _text = _postJson["body"] as! String
        _date = _postJson["date"] as! String
        _image = SnipImage(imageData: _postJson["image"] as! [String : Any])
        _relatedLinks = _postJson["related_links"] as! [[String : Any]]
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
