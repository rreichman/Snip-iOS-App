//
//  LogInfo.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/30/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class LogInfo
{
    var logID : Int = 0
    var logInfo : Dictionary<String,String> = Dictionary<String,String>()
    
    init(receivedLogID : Int, receivedLogInfo : Dictionary<String,String>)
    {
        logID = receivedLogID
        logInfo = receivedLogInfo
    }
}
