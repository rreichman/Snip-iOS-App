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
    
    
    var areTherePostsRemainingOnServer : Bool = true
    var csrfTokenValue : String = ""
    var currentUrlString : String = SystemVariables().URL_STRING
    var feedDataSource = FeedDataSource()
    var lock : NSLock = NSLock()
    
    func clean()
    {
        areTherePostsRemainingOnServer = true
        csrfTokenValue = ""
        currentUrlString = SystemVariables().URL_STRING
        feedDataSource = FeedDataSource()
        lock.unlock()
    }
    
    func runFunctionAfterGettingCsrfToken(functionData : Any, completionHandler: @escaping (_ handlerParams : Any, _ csrfToken : String) -> ())
    {
        if csrfTokenValue != ""
        {
            completionHandler(functionData, csrfTokenValue)
        }
        else
        {
            getCookiesFromServer(handlerParams: functionData, completionHandler: completionHandler)
        }
    }
    
    func getCookiesFromServer(handlerParams : Any, completionHandler: @escaping (_ handlerParams : Any, _ csrfToken : String) -> ())
    {
        let url : URL = URL(string: SystemVariables().URL_STRING)!
        
        let cookieStorage = HTTPCookieStorage.shared
        let cookieHeaderField = ["Set-Cookie": "key=value"]
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: url)
        cookieStorage.setCookies(cookies, for: url, mainDocumentURL: url)
        
        var urlRequest: URLRequest = URLRequest(url: url)
        urlRequest.httpShouldHandleCookies = true
        
        // TODO:: handle situation of no Internet connection
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
            completionHandler(handlerParams, self.csrfTokenValue)
        }).resume()
    }
    
    func getSnipsJsonFromWebServer(completionHandler: @escaping (_ dataSource : FeedDataSource) -> ())
    {
        let url: URL = URL(string: currentUrlString)!
        var urlRequest: URLRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if (!areTherePostsRemainingOnServer)
        {
            return
        }
        
        //fetching the data from the url
        URLSession.shared.dataTask(with: urlRequest, completionHandler: {(data, response, error) -> Void in
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : Any]
            {
                self.loadDataFromWebIntoFeed(resultArray: jsonObj, completionHandler: completionHandler)
            }
        }).resume()
    }
    
    func nilFunction(responseString : String)
    {
        print("doing nothing")
    }
    
    func postContentWithJsonBody(jsonString : Dictionary<String,String>, urlString : String, csrfToken : String)
    {
        postContentWithJsonBody(jsonString: jsonString, urlString: urlString, csrfToken: csrfToken, completionHandler: nilFunction)
    }
    
    func postContentWithJsonBody(jsonString : Dictionary<String,String>, urlString : String, csrfToken : String, completionHandler : @escaping (_ responseString : String) -> ())
    {
        var urlRequest : URLRequest = getDefaultURLRequest(serverString: urlString, csrfValue: csrfToken)
        
        let commentData : Dictionary<String,String> = jsonString
        let jsonString = convertDictionaryToJsonString(dictionary: commentData)
        urlRequest.httpBody = jsonString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data, error == nil else
            {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200
            {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
            if (completionHandler != nil)
            {
                completionHandler(responseString!)
            }
        }
        task.resume()
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
            if !resultArray.keys.contains("next_page")
            {
                areTherePostsRemainingOnServer = false
            }
            else
            {
                currentUrlString = getNextPage(next_page: resultArray["next_page"] as! Int)
            }
            let newPost = PostData(receivedPostJson : postAsJson)
            
            feedDataSource.postDataArray.append(newPost)
        }
        
        completionHandler(feedDataSource)
    }
    
    func loadMorePosts(completionHandler: @escaping (_ dataSource : FeedDataSource) -> ())
    {
        print("loading more posts")
        if (lock.try())
        {
            getSnipsJsonFromWebServer(completionHandler: completionHandler)
        }
    }
}
