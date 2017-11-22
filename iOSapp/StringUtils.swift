//
//  StringUtils.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/14/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

func getWidthOfSingleChar(font : UIFont) -> Float
{
    let text = NSAttributedString(string: "a", attributes: [NSAttributedStringKey.font : font])
    return Float(text.size().width)
}
