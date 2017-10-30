//
//  PostData.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/29/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class PostData
{
    var _headline : String
    var _text : String
    var _imageURL : String
    
    init()
    {
        _headline = ""
        _text = ""
        _imageURL = ""
    }
    
    init(headline : String, text : String, imageURL : String)
    {
        _headline = headline
        _text = text
        _imageURL = imageURL
    }
}
