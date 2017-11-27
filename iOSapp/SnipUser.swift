//
//  SnipUser.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/26/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

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
