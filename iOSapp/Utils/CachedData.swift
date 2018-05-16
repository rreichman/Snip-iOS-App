//
//  CachedData.swift
//  iOSapp
//
//  Created by Ran Reichman on 12/6/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class CachedData
{
    static let shared = CachedData()
    
    var screenWidth : CGFloat = 0
    var screenHeight : CGFloat = 0
    let paragraphStyle : NSMutableParagraphStyle = NSMutableParagraphStyle()
    var alreadySetParagraphStyle = false
    
    func getScreenWidth() -> CGFloat
    {
        if (screenWidth == 0)
        {
            screenWidth = UIScreen.main.bounds.width
        }

        return screenWidth
    }
    
    func getScreenHeight() -> CGFloat
    {
        if (screenHeight == 0)
        {
            screenHeight = UIScreen.main.bounds.height
        }
        
        return screenHeight
    }
    
    func getParagraphStyle() -> NSMutableParagraphStyle
    {
        if (!alreadySetParagraphStyle)
        {
            paragraphStyle.hyphenationFactor = 1.0
            paragraphStyle.lineSpacing = SystemVariables().LINE_SPACING_IN_TEXT
            paragraphStyle.paragraphSpacing = 7.0
            alreadySetParagraphStyle = true
        }
        
        return paragraphStyle
    }
}
