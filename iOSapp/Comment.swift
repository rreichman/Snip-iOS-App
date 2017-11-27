//
//  Comment.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/26/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

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
