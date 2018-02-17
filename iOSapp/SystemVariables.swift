//
//  SystemVariables.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/10/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit
import LatoFont

public class SystemVariables
{
    
    // Various fonts
    let NAVIGATION_BAR_TITLE_FONT = UIFont.boldSystemFont(ofSize : 18)
    let HEADLINE_TEXT_FONT = UIFont.latoBold(size: 16)
    let HEADLINE_TEXT_COLOR = UIColor(red:0.2, green:0.2, blue:0.2, alpha:1)
    let CELL_TEXT_FONT = UIFont.lato(size: 14)
    let CELL_TEXT_COLOR = UIColorFromRGB(rgbValue: 0x4c4c4c)
    let IMAGE_DESCRIPTION_HEIGHT = 10
    let IMAGE_DESCRIPTION_TEXT_FONT = UIFont.lato(size: 10)
    let IMAGE_DESCRIPTION_COLOR = UIColor.lightGray
    let PUBLISH_WRITER_FONT = UIFont.latoBold(size: 14)
    let PUBLISH_WRITER_COLOR = UIColor(red:0.2, green:0.2, blue:0.2, alpha:1)
    let PUBLISH_TIME_FONT = UIFont.lato(size: 14)
    let PUBLISH_TIME_COLOR = UIColor(red:0.61, green:0.61, blue:0.61, alpha:1)
    let NUMBER_OF_COMMENTS_FONT = UIFont.lato(size: 16)
    let NUMBER_OF_COMMENTS_COLOR = UIColor(red:0.2, green:0.2, blue:0.2, alpha:1)
    let REFERENCES_FONT = UIFont.lato(size: 11)
    let REFERENCES_COLOR = UIColor.gray
    let LINE_SPACING_IN_REFERENCES = CGFloat(5)
    let LINE_SPACING_IN_COMMENT_PREVIEW = CGFloat(3)
    
    let COMMENT_PREVIEW_AUTHOR_FONT = UIFont.boldSystemFont(ofSize : 14)
    let COMMENT_PREVIEW_TEXT_FONT = UIFont.systemFont(ofSize: 13)
    
    let READ_MORE_TEXT : String = "... Read More"
    let READ_MORE_TEXT_COLOR : UIColor = UIColor.gray
    let READ_MORE_TEXT_FONT = UIFont.lato(size: 15)
    
    let LOGIN_BACKGROUND_COLOR : UIColor = UIColorFromRGB(rgbValue: 0xf6f6f6)
    let LOGIN_BUTTON_COLOR : UIColor = UIColorFromRGB(rgbValue: 0x4d90fe)
    
    let TERMS_AND_CONDITIONS_FONT = UIFont.lato(size: 14)
    
    let PASSWORD_LENGTH_LIMIT = 6
    let DEFAULT_HEIGHT_OF_REPLYING_TO_BAR = 30
    
    // The spacing between lines in the text
    let LINE_SPACING_IN_TEXT = CGFloat(2)
    
    // Number of objects stored in app memory cache
    let MEMORY_COUNT_LIMIT = 20
    
    // Above this number of rows we want to truncate the snippet because it's too long
    let NUMBER_OF_ROWS_TO_TRUNCATE = 6
    let NUMBER_OF_ROWS_IN_PREVIEW = 2
    
    //let URL_STRING = "http://localhost:8000/"
    let URL_STRING = "https://www.snip.today/"
    
    let MAX_LOG_FLUSH_FREQUENCY_IN_SECONDS = 30
    
    let SECONDS_APP_IS_IN_BACKGROUND_BEFORE_REFRESH = 60
    
    let COMMENT_INDENTATION_FROM_LEFT_PER_LEVEL = 25
    
    let TERMS_OF_SERVICE_URL = "https://www.snip.today/about/terms/"
    let PRIVACY_POLICY_URL = "https://www.snip.today/about/privacy_policy/"
}
