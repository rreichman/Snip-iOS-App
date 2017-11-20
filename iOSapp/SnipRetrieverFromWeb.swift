//
//  SnipRetriever.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/14/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class SnipRetrieverFromWeb
{
    static let shared = SnipRetrieverFromWeb()
    
    var csrfTokenValue : String = ""
    var currentUrlString = SystemVariables().URL_STRING
    let feedDataSource = FeedDataSource()
    
    func runLogFunctionAfterGettingCsrfToken(logID : Int, logInfo : Dictionary<String,String>, completionHandler: @escaping (_ logID : Int, _ logInfo : Dictionary<String,String>, _ csrfToken : String) -> ())
    {
        if csrfTokenValue != ""
        {
            completionHandler(logID, logInfo, csrfTokenValue)
        }
        else
        {
            getCookiesFromServer(logID: logID, logInfo: logInfo, completionHandler: completionHandler)
        }
    }
    
    func getCookiesFromServer(logID : Int, logInfo : Dictionary<String,String>, completionHandler: @escaping (_ logID : Int, _ logInfo : Dictionary<String,String>, _ csrfToken : String) -> ())
    {
        let url : URL = URL(string: SystemVariables().URL_STRING)!
        
        let cookieStorage = HTTPCookieStorage.shared
        let cookieHeaderField = ["Set-Cookie": "key=value"]
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: url)
        cookieStorage.setCookies(cookies, for: url, mainDocumentURL: url)
        
        var urlRequest: URLRequest = URLRequest(url: url)
        urlRequest.httpShouldHandleCookies = true
        
        URLSession.shared.dataTask(with: urlRequest, completionHandler: {(data, response, error) -> Void in
            let httpResponse = response as! HTTPURLResponse
            let responseHeaderFields = httpResponse.allHeaderFields as! [String : String]
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: responseHeaderFields, for: url)
            for cookie in cookies
            {
                if cookie.name == "csrftoken"
                {
                    self.csrfTokenValue = cookie.value
                }
            }
            completionHandler(logID, logInfo, self.csrfTokenValue)
        }).resume()
    }
    
    func getSnipsJsonFromWebServer(completionHandler: @escaping (_ dataSource : FeedDataSource) -> ())
    {
        let url: URL = URL(string: currentUrlString)!
        var urlRequest: URLRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        //fetching the data from the url
        URLSession.shared.dataTask(with: urlRequest, completionHandler: {(data, response, error) -> Void in
            print(data)
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : Any]
            {
                self.loadDataFromWebIntoFeed(resultArray: jsonObj, completionHandler: completionHandler)
            }
        }).resume()
    }

    func getNextPage(next_page : Int) -> String
    {
        return SystemVariables().URL_STRING + "?page=" + String(next_page)
    }

    func loadDataFromWebIntoFeed(resultArray: [String : Any], completionHandler: @escaping (_ dataSource : FeedDataSource) -> ())
    {
        let postsAsJson : [[String : Any]] = resultArray["posts"] as! [[String : Any]]
        
        for postAsJson in postsAsJson
        {
            currentUrlString = getNextPage(next_page: resultArray["next_page"] as! Int)
            let newPost = PostData(receivedPostJson : postAsJson)
            
            feedDataSource.postDataArray.append(newPost)
        }
        
        completionHandler(feedDataSource)
    }
    
    func loadMorePosts(completionHandler: @escaping (_ dataSource : FeedDataSource) -> ())
    {
        getSnipsJsonFromWebServer(completionHandler: completionHandler)
    }
}
