//
//  UserInformation.swift
//  iOSapp
//
//  Created by Ran Reichman on 12/3/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class UserInformation
{
    var authenticationTokenKey : String = "key"
    var emailKey : String = "email"
    var firstNameKey : String = "firstname"
    var lastNameKey : String = "lastname"
    var usernameKey : String = "username"

    func getUserInfo(key: String) -> String
    {
        var userKey = UserDefaults.standard.object(forKey: key)
        if (userKey == nil)
        {
            userKey = ""
        }
        
        return userKey as! String
    }

    func setUserInfo(key: String, value : String)
    {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func isUserLoggedIn() -> Bool
    {
        return (getUserInfo(key: "key") != "")
    }
    
    func logOutUser()
    {
        setUserInfo(key: authenticationTokenKey, value: "")
        setUserInfo(key: emailKey, value: "")
        setUserInfo(key: firstNameKey, value: "")
        setUserInfo(key: lastNameKey, value: "")
        setUserInfo(key: usernameKey, value: "")
    }
}
