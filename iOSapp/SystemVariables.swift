//
//  SystemVariables.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/10/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

public class SystemVariables
{
    // Various fonts
    let NAVIGATION_BAR_TITLE_FONT = UIFont.boldSystemFont(ofSize : 18)
    let HEADLINE_TEXT_FONT = UIFont.boldSystemFont(ofSize: 14)
    let CELL_TEXT_FONT = UIFont(name: "Helvetica", size: 13)
    
    // The spacing between lines in the text
    let LINE_SPACING_IN_TEXT = CGFloat(2)
    
    // Number of objects stored in app memory cache
    let MEMORY_COUNT_LIMIT = 20
    
    // Above this number of rows we want to truncate the snippet because it's too long
    let NUMBER_OF_ROWS_TO_TRUNCATE = 6
    let NUMBER_OF_ROWS_IN_PREVIEW = 2
    
    let URL_STRING = "https://www.snip.today/"
}
