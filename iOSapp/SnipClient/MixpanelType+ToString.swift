//
//  MixpanelType+String.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/20/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit
import Mixpanel

extension MixpanelType
{
    func toString() -> String
    {
        if self is String
        {
            return self as! String
        }
        if self is Int
        {
            return String(self as! Int)
        }
        if self is UInt
        {
            return String(self as! UInt)
        }
        if self is Double
        {
            return String(self as! Double)
        }
        if self is Float
        {
            return String(self as! Float)
        }
        if self is Bool
        {
            return String(self as! Bool)
        }
        if self is Date
        {
            return (self as! Date).description
        }
        if self is URL
        {
            return (self as! URL).absoluteString
        }
        if self is NSNull
        {
            return "null"
        }
        return "unstringableMixpanelType"
    }
}
