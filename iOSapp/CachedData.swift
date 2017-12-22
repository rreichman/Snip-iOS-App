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
    
    func getScreenWidth() -> CGFloat
    {
        if (screenWidth == 0)
        {
            screenWidth = UIScreen.main.bounds.width
        }

        return screenWidth
    }
}
