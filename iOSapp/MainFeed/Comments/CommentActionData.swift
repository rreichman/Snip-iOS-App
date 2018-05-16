//
//  CommentData.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/30/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class CommentActionData
{
    var actionString : String = ""
    var actionJson : Dictionary<String,String> = Dictionary<String,String>()
    
    init(receivedActionString : String, receivedActionJson : Dictionary<String,String>)
    {
        actionString = receivedActionString
        actionJson = receivedActionJson
    }
}
