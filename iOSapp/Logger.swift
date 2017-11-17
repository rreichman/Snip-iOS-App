//
//  Logger.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/17/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit
import Mixpanel

public class Logger
{
    static let shared = Logger()
    // Initializing to historic time.
    var lastFlushDate : Date = Date(timeIntervalSince1970: 0)
    
    private func logEvent(eventName : String, eventProperties : Dictionary<String,MixpanelType>)
    {
        Mixpanel.mainInstance().track(event: eventName, properties: eventProperties)
        //var logData :  = Dictionary<String,String>()
        //logData
        
        var storedJson : Dictionary<String,String> = Dictionary<String,String>()
        do
        {
            try storedJson = AppCache.shared.getStorage().object(ofType: Dictionary<String,String>.self, forKey: "log")
        }
        catch
        {
            // Do nothing
        }
    }
    
    func logStartedSplashScreen()
    {
        logEvent(eventName: "enteredSplashScreen", eventProperties: [:])
    }
    
    func logEnteredTableView()
    {
        
    }
    
    func logReadMoreEvent()
    {
        
    }
    
    func logReadLessEvent()
    {
        
    }
    
    func logScrolledToInfiniteScroll()
    {
        
    }
    
    func logClickedLike()
    {
        
    }
    
    func logClickedDislike()
    {
        
    }
}
