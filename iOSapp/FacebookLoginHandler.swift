//
//  FacebookLoginHandler.swift
//  iOSapp
//
//  Created by Ran Reichman on 12/15/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit
import FacebookLogin

func facebookResultHandler(loginResult : LoginResult)
{
    switch loginResult
    {
    case LoginResult.failed(let error):
        print(error)
    case LoginResult.cancelled:
        print("User cancelled login.")
    case LoginResult.success(let grantedPermissions, let declinedPermissions, let accessToken):
        print("Login is successful!")
    }
}
