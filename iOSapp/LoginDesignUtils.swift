//
//  DesignUtils.swift
//  iOSapp
//
//  Created by Ran Reichman on 3/28/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

public class LoginDesignUtils
{
    let LABEL_PASSIVE_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().LOGIN_LABEL_FONT!, NSAttributedStringKey.foregroundColor : UIColor(red:0.61, green:0.61, blue:0.61, alpha:1)]
    let LABEL_ACTIVE_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().LOGIN_LABEL_FONT!, NSAttributedStringKey.foregroundColor : SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR]
    
    let HEADLINE_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().LOGIN_SIGNUP_BUTTON_FONT!, NSAttributedStringKey.foregroundColor : UIColor.white]
    
    let FORGOT_PASSWORD_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().FORGOT_PASSWORD_FONT!, NSAttributedStringKey.foregroundColor : UIColor(red:0.61, green:0.61, blue:0.61, alpha:1)]
    let FORGOT_PASSWORD_ACTIVE_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().FORGOT_PASSWORD_FONT!, NSAttributedStringKey.foregroundColor : SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR]
}
