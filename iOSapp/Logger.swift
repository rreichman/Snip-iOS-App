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
    var dateOfLastSuccessfulFlush : Date = Date(timeIntervalSince1970: 0)
    // This is used to clean local logs
    var logsNotYetSentToServer : [Int : Dictionary<String,String>] = [:]
    
    init()
    {
        do
        {
            if (try AppCache.shared.getStorage().existsObject(ofType: [Int : Dictionary<String,String>].self, forKey: "log"))
            {
                logsNotYetSentToServer = try AppCache.shared.getStorage().object(ofType: [Int : Dictionary<String,String>].self, forKey: "log")
            }
            
            try AppCache.shared.getStorage().setObject(logsNotYetSentToServer, forKey: "log")
        }
        catch
        {
            // Do nothing
        }
    }
    
    private func finishPosting(logID : Int)
    {
        logsNotYetSentToServer.remove(at: logsNotYetSentToServer.index(forKey: logID)!)
        dateOfLastSuccessfulFlush = Date()
    }
    
    private func sendLogsToServer()
    {
        for logID in logsNotYetSentToServer.keys
        {
            SnipRetrieverFromWeb().runLogFunctionAfterGettingCsrfToken(
                logID: logID, logInfo: logsNotYetSentToServer[logID]!, completionHandler: self.sendLogToServer)
        }
    }
    
    private func convertDictionaryToJsonString(dictionary: Dictionary<String,String>) -> String
    {
        var dictionaryString = ""
        var isFirstKey = true
        
        for key in dictionary.keys
        {
            if !isFirstKey
            {
                dictionaryString.append("&")
            }
            isFirstKey = false
            
            dictionaryString.append(key)
            dictionaryString.append("=")
            dictionaryString.append(dictionary[key]!)
        }
        return dictionaryString
    }
    
    private func getServerStringForLog(logInfo : Dictionary<String,String>) -> String
    {
        var baseURLString : String = SystemVariables().URL_STRING
        
        if logInfo.keys.contains("snipid")
        {
            baseURLString.append("action/")
            baseURLString.append(logInfo["snipid"]!)
            baseURLString.append("/")
        }
        else
        {
            baseURLString.append("user/log/")
        }
        return baseURLString
    }
    
    private func sendLogToServer(logID : Int, logInfo : Dictionary<String,String>, csrfValue : String)
    {
        let url: URL = URL(string: getServerStringForLog(logInfo: logInfo))!
        var urlRequest: URLRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "POST"
        urlRequest.setValue(csrfValue, forHTTPHeaderField: "X-CSRFTOKEN")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        //let jsonData = try? JSONSerialization.data(withJSONObject: logInfo)
        // Note - the current implementation is perhaps not ideal and should use JSONSerialization but otherwise need to change server side
        let jsonString = convertDictionaryToJsonString(dictionary: logInfo)
        urlRequest.httpBody = jsonString.data(using: String.Encoding.utf8)
        
        //sending the data to the url
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data, error == nil else
            {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200
            {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            self.finishPosting(logID: logID)
        }
        task.resume()
    }
    
    private func logEvent(actionName : String, eventProperties : Dictionary<String,MixpanelType>)
    {
        Mixpanel.mainInstance().track(event: actionName, properties: eventProperties)
        var currentLog : Dictionary<String,String> = Dictionary<String,String>()
        currentLog["action"] = actionName
        currentLog["appleid"] = getUniqueDeviceID()
        for eventProperty in eventProperties.keys
        {
            currentLog[eventProperty] = eventProperties[eventProperty]?.toString()
        }
        
        do
        {
            let logID : Int = Int(arc4random())
            logsNotYetSentToServer[logID] = currentLog
            
            let currentDate : Date = Date()
            if (currentDate.seconds(from: dateOfLastSuccessfulFlush) > SystemVariables().MAX_LOG_FLUSH_FREQUENCY_IN_SECONDS)
            {
                sendLogsToServer()
            }
            else
            {
                try AppCache.shared.getStorage().setObject(logsNotYetSentToServer, forKey: "log")
            }
        }
        catch
        {
            Mixpanel.mainInstance().track(event: "LogFailEvent", properties: [:])
            // Do nothing
        }
    }
    
    private func logEvent(actionName : String)
    {
        logEvent(actionName: actionName, eventProperties: [:])
    }
    
    func logStartedSplashScreen()
    {
        logEvent(actionName: "inSplash")
    }
    
    func logEnteredTableView()
    {
        logEvent(actionName: "inTableView")
    }
    
    func logReadMoreEvent(snipID : Int)
    {
        logEvent(actionName: "readMore", eventProperties: ["snipid" : snipID])
    }
    
    func logReadLessEvent(snipID : Int)
    {
        logEvent(actionName: "readLess", eventProperties: ["snipid" : snipID])
    }
    
    func logTapOnNonTruncableText(snipID: Int)
    {
        logEvent(actionName: "tappedText", eventProperties: ["snipid" : snipID])
    }
    
    func logScrolledToInfiniteScroll()
    {
        logEvent(actionName: "infiniteScroll")
    }
    
    func logClickedLikeOrDislike(isLikeClick : Bool, snipID : Int, wasClickedBefore : Bool)
    {
        var actionName = "clickedLike"
        var wasLikedPropertyKey = "wasLikeBefore"
        
        if !isLikeClick
        {
            actionName = "clickedDislike"
            wasLikedPropertyKey = "wasDislikedBefore"
        }
        
        logEvent(actionName: actionName, eventProperties: ["snipid" : snipID, wasLikedPropertyKey : wasClickedBefore])
    }
}
