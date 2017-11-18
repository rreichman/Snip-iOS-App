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
    
    //request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    //let postString = "id=13&name=Jack"
    //request.httpBody = postString.data(using: .utf8)
    
    private func sendLogsToServer()
    {
        for logID in logsNotYetSentToServer.keys
        {
            // TODO:: return this
            //sendLogToServer(logID: logID, logInfo: logsNotYetSentToServer[logID]!)
        }
    }
    
    private func sendLogToServer(logID : Int, logInfo : Dictionary<String,String>)
    {
        let url: URL = URL(string: SystemVariables().POST_LOG_URL_STRING)!
        var urlRequest: URLRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
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
    
    private func logEvent(eventName : String, eventProperties : Dictionary<String,MixpanelType>)
    {
        Mixpanel.mainInstance().track(event: eventName, properties: eventProperties)
        var currentLog : Dictionary<String,String> = Dictionary<String,String>()
        currentLog["name"] = eventName
        
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
