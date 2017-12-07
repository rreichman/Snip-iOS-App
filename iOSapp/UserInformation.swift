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
    var firstNameKey : String = "first_name"
    var lastNameKey : String = "last_name"
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
    
    func getUserInformationFromWeb()
    {
        if isUserLoggedIn()
        {
            var currentUrlString = SystemVariables().URL_STRING
            currentUrlString.append("user/my_profile/")
            
            let url: URL = URL(string: currentUrlString)!
            var urlRequest: URLRequest = URLRequest(url: url)
            
            urlRequest.httpMethod = "GET"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            urlRequest.setValue(getAuthorizationString(), forHTTPHeaderField: "Authorization")
            
            //fetching the data from the url
            URLSession.shared.dataTask(with: urlRequest, completionHandler: {(data, response, error) -> Void in
                if (response != nil)
                {
                    if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : Any]
                    {
                        print(jsonObj)
                        for key in jsonObj.keys
                        {
                            UserInformation().setUserInfo(key: key, value: jsonObj[key] as! String)
                        }
                    }
                    else
                    {
                        print(response)
                    }
                }
                else
                {
                    // TODO:: log this error
                }
            }).resume()
        }
    }
}
