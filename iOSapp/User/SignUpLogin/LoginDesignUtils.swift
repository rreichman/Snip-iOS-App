//
//  DesignUtils.swift
//  iOSapp
//
//  Created by Ran Reichman on 3/28/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

let LABEL_PASSIVE_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().LOGIN_LABEL_FONT!, NSAttributedStringKey.foregroundColor : UIColor(red:0.61, green:0.61, blue:0.61, alpha:1)]
let LABEL_ACTIVE_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().LOGIN_LABEL_FONT!, NSAttributedStringKey.foregroundColor : SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR]
let HEADLINE_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().LOGIN_SIGNUP_BUTTON_FONT!, NSAttributedStringKey.foregroundColor : UIColor.white]

class LoginDesignUtils
{
    static let shared = LoginDesignUtils()
    
    let FORGOT_PASSWORD_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().FORGOT_PASSWORD_FONT!, NSAttributedStringKey.foregroundColor : UIColor(red:0.61, green:0.61, blue:0.61, alpha:1)]
    let FORGOT_PASSWORD_ACTIVE_ATTRIBUTES : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : SystemVariables().FORGOT_PASSWORD_FONT!, NSAttributedStringKey.foregroundColor : SystemVariables().SPLASH_SCREEN_BACKGROUND_COLOR]
    
    let EMAIL_ACTIVE_STRING : NSAttributedString = NSAttributedString(string: "Email", attributes: LABEL_ACTIVE_ATTRIBUTES)
    let EMAIL_PASSIVE_STRING : NSAttributedString = NSAttributedString(string: "Email", attributes: LABEL_PASSIVE_ATTRIBUTES)
    let PASSWORD_ACTIVE_STRING : NSAttributedString = NSAttributedString(string: "Password", attributes: LABEL_ACTIVE_ATTRIBUTES)
    let PASSWORD_PASSIVE_STRING : NSAttributedString = NSAttributedString(string: "Password", attributes: LABEL_PASSIVE_ATTRIBUTES)
    let FIRST_NAME_ACTIVE_STRING : NSAttributedString = NSAttributedString(string: "First Name", attributes: LABEL_ACTIVE_ATTRIBUTES)
    let FIRST_NAME_PASSIVE_STRING : NSAttributedString = NSAttributedString(string: "First Name", attributes: LABEL_PASSIVE_ATTRIBUTES)
    let LAST_NAME_ACTIVE_STRING : NSAttributedString = NSAttributedString(string: "Last Name", attributes: LABEL_ACTIVE_ATTRIBUTES)
    let LAST_NAME_PASSIVE_STRING : NSAttributedString = NSAttributedString(string: "Last Name", attributes: LABEL_PASSIVE_ATTRIBUTES)
    let SHOW_TEXT = NSAttributedString(string: "Show", attributes: [NSAttributedStringKey.font : SystemVariables().FORGOT_PASSWORD_FONT!, NSAttributedStringKey.foregroundColor : UIColor(red:0.61, green:0.61, blue:0.61, alpha:1)])
    let HIDE_TEXT = NSAttributedString(string: "Hide", attributes: [NSAttributedStringKey.font : SystemVariables().FORGOT_PASSWORD_FONT!, NSAttributedStringKey.foregroundColor : UIColor(red:0.61, green:0.61, blue:0.61, alpha:1)])
    
    let SIGNUP_TEXT = NSAttributedString(string: "Sign Up", attributes: HEADLINE_ATTRIBUTES)
    
    let TERMS_AND_CONDITIONS_STRING = getTermsAndConditionsString(color: SystemVariables().TERMS_AND_CONDITIONS_COLOR)
    
    let SAVED_SNIPS_HEADLINE_STRING = NSAttributedString(string: "Saved Snips", attributes: HEADLINE_ATTRIBUTES)
    let SETTINGS_HEADLINE_STRING = NSAttributedString(string: "Settings", attributes: HEADLINE_ATTRIBUTES)
    let COMMENTS_HEADLINE_STRING = NSAttributedString(string: "Comments", attributes: HEADLINE_ATTRIBUTES)
    let HOME_HEADLINE_STRING = NSAttributedString(string: "Home", attributes: HEADLINE_ATTRIBUTES)
    
    let PRIVACY_POLICY_STRING = NSAttributedString(string: "Privacy Policy", attributes: SETTINGS_MEMBER_DESCRIPTION_ATTRIBUTES)
    let TERMS_OF_SERVICE_STRING = NSAttributedString(string: "Terms Of Service", attributes: SETTINGS_MEMBER_DESCRIPTION_ATTRIBUTES)
    let LOGOUT_STRING = NSAttributedString(string: "Logout", attributes: SETTINGS_MEMBER_DESCRIPTION_ATTRIBUTES)
    let NOTIFICATION_STRING = NSAttributedString(string: "Enable Notifications", attributes: SETTINGS_MEMBER_DESCRIPTION_ATTRIBUTES)
    
    let LOGIN_STRING = NSAttributedString(string: "Login", attributes: HEADLINE_ATTRIBUTES)
    let LOGIN_STRING_BOTTOM = NSAttributedString(string: "Log In", attributes: HEADLINE_ATTRIBUTES)
    let FORGOT_PASSWORD_STRING = NSAttributedString(string: "Forgot?", attributes: [NSAttributedStringKey.font : SystemVariables().FORGOT_PASSWORD_FONT!, NSAttributedStringKey.foregroundColor : UIColor(red:0.61, green:0.61, blue:0.61, alpha:1)])
}
