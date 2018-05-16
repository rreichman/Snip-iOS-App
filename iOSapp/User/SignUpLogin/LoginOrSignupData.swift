//
//  LoginOrSignupData.swift
//  iOSapp
//
//  Created by Ran Reichman on 12/15/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class LoginOrSignupData
{
    var _urlString : String = ""
    var _postJson : Dictionary<String,String> = Dictionary<String,String>()
    
    init(urlString : String, postJson : Dictionary<String,String>)
    {
        _urlString = SystemVariables().URL_STRING
        _urlString.append(urlString)
        _postJson = postJson
    }
}
