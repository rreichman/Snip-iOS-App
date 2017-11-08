//
//  PostData.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/29/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit
import Cache

class PostData
{
    var _id : Int
    var _author : SnipAuthor
    var _headline : String
    var _text : String
    // TODO: perhaps store the date as something else in the future (not sure)
    var _date : String
    var _image : SnipImage
    
    init()
    {
        _id = 0
        _author = SnipAuthor()
        _headline = ""
        _text = ""
        _date = ""
        _image = SnipImage()
    }
    
    init(id : Int, author : SnipAuthor, headline : String, text : String, date : String, image : SnipImage)
    {
        _id = id
        _author = author
        _headline = headline
        _text = text
        _date = date
        _image = image
    }
}

class SnipAuthor
{
    public var _authorUsername : String
    public var _authorName : String
    
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

class SnipImage
{
    public var _imageURL : String
    public var _imageDescription : String
    
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
