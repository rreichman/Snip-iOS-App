//
//  ReportInfo.swift
//  iOSapp
//
//  Created by Ran Reichman on 2/27/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

class ReportInfo
{
    var _snippetID : Int = 0
    var _reasons : String = ""
    
    init(snippetID : Int, reasons : String)
    {
        _snippetID = snippetID
        _reasons = reasons
    }
    
    func getDataAsDictionary() -> Dictionary<String,String>
    {
        var dataDictionary : Dictionary<String,String> = Dictionary<String,String>()
        dataDictionary["post_id"] = String(_snippetID)
        dataDictionary["reason_list_str"] = _reasons
        
        return dataDictionary
    }
}
