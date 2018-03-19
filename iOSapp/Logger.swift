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
            //WebUtils().runFunctionAfterGettingCsrfToken(
                //functionData: LogInfo(receivedLogID: logID, receivedLogInfo: logsNotYetSentToServer[logID]!), completionHandler: self.sendLogToServer)
            sendLogToServer(logParams: LogInfo(receivedLogID: logID, receivedLogInfo: logsNotYetSentToServer[logID]!))
        }
    }
    
    private func getServerStringForLog(logInfo : Dictionary<String,String>) -> String
    {
        var urlString : String = SystemVariables().URL_STRING
        
        if logInfo.keys.contains("snipid")
        {
            urlString.append("action/")
            urlString.append(logInfo["snipid"]!)
            urlString.append("/")
        }
        else
        {
            urlString.append("user/log/")
        }
        return urlString
    }
    
    private func sendLogToServer(logParams : Any)
    {
        let convertedLogParams : LogInfo = logParams as! LogInfo
        let logID : Int = convertedLogParams.logID
        let logInfo : Dictionary<String,String> = convertedLogParams.logInfo
        
        var serverString = getServerStringForLog(logInfo: logInfo)
        let url: URL = URL(string: serverString)!
        var urlRequest = getDefaultURLRequest(serverString: serverString, method: "POST")
        
        //let jsonData = try? JSONSerialization.data(withJSONObject: logInfo)
        // Note - the current implementation is perhaps not ideal and should use JSONSerialization but otherwise need to change server side
        let jsonString = convertDictionaryToJsonString(dictionary: logInfo)
        urlRequest.httpBody = jsonString.data(using: String.Encoding.utf8)
        
        //sending the data to the url
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if (response != nil)
            {
                SnipRetrieverFromWeb.shared.handleResponse(response: response as! HTTPURLResponse, url: url)
            }
            guard let _ = data, error == nil else
            {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            SnipRetrieverFromWeb.shared.handleResponse(response: response as! HTTPURLResponse, url: urlRequest.url!)
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200
            {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            //let responseString = String(data: data, encoding: .utf8)
            //print("responseString = \(String(describing: responseString))")
            self.finishPosting(logID: logID)
        }
        task.resume()
    }
    
    private func logEvent(actionName : String, eventProperties : Dictionary<String,MixpanelType>, shouldFlushNow : Bool)
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
            if ((currentDate.seconds(from: dateOfLastSuccessfulFlush) > SystemVariables().MAX_LOG_FLUSH_FREQUENCY_IN_SECONDS) || shouldFlushNow)
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
        logEvent(actionName: actionName, eventProperties: [:], shouldFlushNow: false)
    }
    
    func logStartedSplashScreen()
    {
        logEvent(actionName: "inSplash")
    }
    
    func logEnteredTableView()
    {
        logEvent(actionName: "inTableView")
    }
    
    func logRefreshOfTableView()
    {
        logEvent(actionName: "refreshTable")
    }
    
    func logReadMoreEvent(snipID : Int)
    {
        logEvent(actionName: "readmore", eventProperties: ["snipid" : snipID], shouldFlushNow: false)
    }
    
    func logReadLessEvent(snipID : Int)
    {
        logEvent(actionName: "readless", eventProperties: ["snipid" : snipID], shouldFlushNow: false)
    }
    
    func logTapOnNonTruncableText(snipID: Int)
    {
        logEvent(actionName: "tappedText", eventProperties: ["snipid" : snipID], shouldFlushNow: false)
    }
    
    func logScrolledToInfiniteScroll()
    {
        logEvent(actionName: "infiniteScroll")
    }
    
    func logClickCommentButton()
    {
        logEvent(actionName: "clickCommentButton")
    }
    
    func logClickShareButton()
    {
        logEvent(actionName: "clickShareButton")
    }
    
    func logClickSnippetMenuButton()
    {
        logEvent(actionName: "clickSnippetMenuButton")
    }
    
    func logInternetConnectionFailed()
    {
        logEvent(actionName: "connectionFailed")
    }
    
    func logErrorInSnippetCollecting()
    {
        logEvent(actionName: "snipCollectionFailed")
    }
    
    func logAppEnteredBackground()
    {
        logEvent(actionName: "inBackground")
    }
    
    func logAppBecameActive()
    {
        logEvent(actionName: "appBecameActive")
    }
    
    func logWeirdNumberOfSnippetsOnScreen(numberOfSnippets : Int)
    {
        logEvent(actionName: "manyOnScreen", eventProperties: ["numberOfSnips" : numberOfSnippets], shouldFlushNow: false)
    }
    
    func logViewingSnippet(snippetID : Int)
    {
        logEvent(actionName: "viewed", eventProperties: ["snipid" : snippetID], shouldFlushNow: false)
    }
    
    func logClickedLikeOrDislike(isLikeClick : Bool, snipID : Int, wasClickedBefore : Bool)
    {
        var actionName = "like"
        // Note - param_1 is the property key of wasClickedBefore
        let wasLikedDislikedPropertyKey = "param1"
        var wasClickedBeforePropertyName = "mark_vote"
        
        if (wasClickedBefore)
        {
            wasClickedBeforePropertyName = "remove_vote"
        }
        
        if !isLikeClick
        {
            actionName = "dislike"
        }
        
        logEvent(actionName: actionName, eventProperties: ["snipid" : snipID, wasLikedDislikedPropertyKey : wasClickedBeforePropertyName], shouldFlushNow: true)
    }
}
