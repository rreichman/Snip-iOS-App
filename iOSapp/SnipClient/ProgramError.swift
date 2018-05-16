//
//  ProgramError.swift
//  iOSapp
//
//  Created by Ran Reichman on 10/27/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

public class ProgramError : Error
{
    var _errorNumber : Int = 0
    var _errorMessage : String = "No Error"
    
    init()
    {
    }
    
    init(errorNumber : Int)
    {
        _errorNumber = errorNumber
        
    }
    
    init(errorMessage : String)
    {
        _errorMessage = errorMessage
    }
}
