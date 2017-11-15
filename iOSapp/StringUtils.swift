//
//  StringUtils.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/14/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

func getWidthOfSingleChar(string : NSAttributedString) -> Float
{
    let NUMBER_OF_CHARS_TO_CHECK = min(60,string.length)
    let firstXChars : NSAttributedString = string.attributedSubstring(from: NSRange(location: 0,length: NUMBER_OF_CHARS_TO_CHECK))
    return (Float(firstXChars.size().width) / Float(NUMBER_OF_CHARS_TO_CHECK))
}
